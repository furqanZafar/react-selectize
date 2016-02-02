# prelude ls 
{each, filter, find, find-index, id, initial, last, map, obj-to-pairs, 
partition, reject, reverse, Str, sort-by, sum, values} = require \prelude-ls

{clamp, is-equal-to-object} = require \prelude-extension
{DOM:{div, input, span}, create-class, create-factory}:React = require \react
{find-DOM-node} = require \react-dom
ReactCSSTransitionGroup = create-factory require \react-addons-css-transition-group
Tether = create-factory require \./Tether
Div = create-factory require \./Div
OptionWrapper = create-factory require \./OptionWrapper
ValueWrapper = create-factory require \./ValueWrapper
{cancel-event, class-name-from-object} = require \./utils

module.exports = create-class do

    display-name: \ReactSelectize

    # used to figure out if the focus event was triggered by external action or by @focus-on-input!
    focus-lock: false

    # used to block default behaviour of option.mouseover when triggered by scrolling using arrow keys
    scroll-lock: false

    # get-default-props :: () -> Props
    get-default-props: ->
        anchor: null # :: Item
        autofocus: false
        # autosize :: InputElement -> ()
        autosize: ($search) !-> 

            if $search.value.length == 0
                $search.style.width = if !!$search?.current-style then \4px else \2px

            else

                # modern browsers
                if $search.scroll-width > 0
                    $search.style.width = "#{2 + $search.scroll-width}px"

                # IE / Edge
                else

                    # create a dummy input
                    $input = document.create-element \div
                        ..innerHTML = $search.value

                    # copy all the styles from search field to dummy input
                    (
                        if !!$search.current-style 
                            $search.current-style 
                        else 
                            document.default-view ? window .get-computed-style $search
                    )
                        |> obj-to-pairs
                        |> each ([key, value]) -> $input.style[key] = value
                        |> -> $input.style <<< display: \inline-block, width: ""

                    # add the dummy input element to document.body and measure the text width
                    document.body.append-child $input
                    $search.style.width = "#{4 + $input.client-width}px"
                    document.body.remove-child $input

        # class-name :: String
        delimiters: []
        disabled: false
        dropdown-direction: 1
        first-option-index-to-highlight: (options) -> 0
        group-id: (.group-id) # Item -> a
        # groups :: [Group]
        groups-as-columns: false
        highlighted-uid: undefined
        # name :: String, used for creating hidden input element
        on-anchor-change: ((anchor) ->) # Item -> (() -> ()) -> ()
        on-blur: ((e) !->) # Event -> ()
        on-enter: ((highlighted-option) !->) # Item -> ()
        on-focus: ((e) !->) # Event -> ()
        on-highlighted-uid-change: ((uid, callback) !-> ) # (Eq e) => e -> (() -> ()) -> ()
        on-keyboard-selection-failed: ((keycode) !-> ) # Int -> ()
        on-open-change: ((open, callback) !->) # Boolean -> (() -> ()) -> ()
        on-paste: ((e) !-> true) # Event -> Boolean
        on-search-change: ((search, callback) !-> ) # String -> (() -> ()) -> ()
        on-values-change: ((values, callback) !->) # [Item] -> (() -> ()) -> ()
        open: false
        options: [] # [Item]
        
        # render-no-results-found :: () -> ReactElement
        render-no-results-found: -> 
            div class-name: \no-results-found, "No results found"
        
        # render-group-title :: Int -> Group -> ReactElement
        render-group-title: (index, {group-id, title}?) ->
            div do 
                class-name: \simple-group-title
                key: group-id
                title
        
        # render-option :: Int -> Item -> ReactElement
        render-option: ({label, new-option, selectable}?) ->
            is-selectable = (typeof selectable == \undefined) or selectable
            div do 
                class-name: "simple-option #{if is-selectable then '' else 'not-selectable'}"
                span null, if !!new-option then "Add #{label} ..." else label
        
        # render-value :: Int -> Item -> ReactElement        
        render-value: ({label}) ->
            div do 
                class-name: \simple-value
                span null, label
        
        # restore-on-backspace: ((value) -> ) # Item -> String
        # serialize :: [Item] -> String, used for form serialization
        search: ""
        style: {}
        tether: false
        transition-enter: false
        transition-leave: false
        transition-enter-timeout: 200
        transition-leave-timeout: 200
        uid: id # (Eq e) => Item -> e
        values: [] # [Item]

    # render :: () -> ReactElement
    render: ->
        anchor-index = 
            | (typeof @props.anchor == \undefined) or @props.anchor == null => -1
            | _ => (find-index (~> it `@is-equal-to-object` @props.anchor), @props.values) ? @props.values.length - 1

        dynamic-class-name = class-name-from-object do
            "#{@props.class-name}" : 1
            disabled: @props.disabled
            open: @props.open
            flipped: @props.dropdown-direction == -1
            tethered: @props.tether

        # render-selected-values :: [Int] -> [ValueWrapper]
        render-selected-values = (selected-values) ~> 
            selected-values |> map (index) ~> 
                item = @props.values[index]
                uid = @props.uid item
                ValueWrapper do 
                    key: @uid-to-string uid
                    uid: uid
                    item: item
                    render-item: @props.render-value

        # REACT SELECTIZE
        div do 
            class-name: "react-selectize #{dynamic-class-name}"
            style: @props.style
    
            if !!@props.name

                # HIDDEN INPUT (for form submission)
                input do 
                    type: \hidden
                    name: @props.name
                    value: @props.serialize @props.values 

            # CONTROL
            div do 
                class-name: \react-selectize-control
                ref: \control
                on-mouse-down: (e) ~>
                    @props.on-anchor-change do 
                        last @props.values
                        ~> @on-open-change true, ~>
                    cancel-event e
                
                # PLACEHOLDER TEXT
                if @props.search.length == 0 and @props.values.length == 0
                    div do 
                        class-name: \react-selectize-placeholder
                        @props.placeholder

                # LIST OF SELECTED VALUES (BEFORE & INCLUDING THE ANCHOR)
                render-selected-values [0 to anchor-index]
                
                # SEARCH INPUT BOX
                input do
                    disabled: @props.disabled
                    ref: \search
                    type: \text
                    value: @props.search

                    # update the search text & highlight the first option
                    on-change: ({current-target:{value}}) ~> 
                        @props.on-search-change value, ~> 
                            @highlight-and-scroll-to-selectable-option do
                                @props.first-option-index-to-highlight @props.options
                                1

                    # show the list of options (noop if caused by invocation of @focus-on-input function)
                    on-focus: (e) !~>
                        # @focus-lock propery is set to true by invoking the @focus-on-input! method
                        # if @focus-lock is false, it implies this focus event was fired as a result of an external action
                        <~ do ~> (callback) ~> 
                            if !!@focus-lock 
                                callback @focus-lock = false 
                            
                            else 
                                <~ @on-open-change true
                                callback true

                        # invokes on-focus listener with the reason depending on the value of @focus-lock
                        @props.on-focus e

                    on-blur: (e) ~> 
                        # close the dropdown and move the cursor the end
                        <~ @close-dropdown

                        # fire on-blur event listener
                        @props.on-blur e

                    # on-paste :: Event -> Boolean
                    on-paste: @props.on-paste

                    # on-key-down :: Event -> Boolean
                    on-key-down: (e) ~>

                        # always handle the tab, backspace & escape keys
                        switch e.which

                        # BACKSPACE
                        | 8 => 
                            
                            return if @props.search.length > 0 or anchor-index == -1

                            do ~>
                                # compute the next-anchor
                                anchor-index-on-remove = anchor-index
                                next-anchor = if (anchor-index - 1) < 0 then undefined else @props.values[anchor-index - 1]

                                # remove the item at the current carret position, 
                                # by requesting the user to update the values array, 
                                # via (@props.on-value-change new-values, callback)
                                value-to-remove = @props.values[anchor-index]
                                <~ @props.on-values-change do 
                                    (@props.values |> reject ~> it `@is-equal-to-object` value-to-remove) ? []

                                # result is true if the user removed the value we requested him to remove
                                result <~ do ~> (callback) ~>

                                    if typeof (find (~> it `@is-equal-to-object` value-to-remove), @props.values) == \undefined

                                        if !!@props.restore-on-backspace
                                            <~ @props.on-search-change @props.restore-on-backspace value-to-remove
                                            callback true

                                        else 
                                            callback true

                                    else 
                                        callback false

                                if !!result

                                    # highlight the first option in the dropdown 
                                    @highlight-and-scroll-to-selectable-option do 
                                        @props.first-option-index-to-highlight @props.options
                                        1

                                    # change the anchor iff the user removed the requested value 
                                    # and the predicted next-anchor is still present
                                    if anchor-index == anchor-index-on-remove and (
                                        typeof next-anchor == \undefined or 
                                        !!(@props.values |> find ~> it `@is-equal-to-object` next-anchor)
                                    )
                                       <~ @props.on-anchor-change next-anchor

                            cancel-event e

                        # ESCAPE
                        | 27 =>
                            # first hit closes the list of options, second hit will reset the selected values
                            <~ do ~> 
                                if @props.open 
                                    ~> @on-open-change false, it
                                else 
                                    ~> @props.on-values-change [], it
                            <~ @props.on-search-change ""
                            @focus-on-input!

                        # ENTER
                        if @props.open and 
                           e.which in [13] ++ @props.delimiters and
                           # do not interfere with hotkeys like control + enter or command + enter
                           !(e?.meta-key or e?.ctrl-key)
                            
                            # select the highlighted option (if any)
                            @select-highlighted-uid anchor-index, (selected-value) ~>
                                if typeof selected-value == \undefined
                                    @props.on-keyboard-selection-failed e.which

                            return cancel-event e

                        # move anchor position left / right using arrow keys (only when search field is empty)
                        if @props.search.length == 0
                            
                            switch e.which

                            # LEFT ARROW
                            | 37 =>
                                @props.on-anchor-change do
                                   if ((anchor-index - 1) < 0 or e.meta-key) 
                                       undefined 
                                   else 
                                       @props.values[clamp (anchor-index - 1), 0, (@props.values.length - 1)]
                                   (->)

                            # RIGHT ARROW
                            | 39 =>
                                @props.on-anchor-change do
                                   if e.meta-key 
                                       last @props.values 
                                   else 
                                       @props.values[clamp (anchor-index + 1), 0, (@props.values.length - 1)]
                                   (->)

                        switch e.which

                            # wrap around upon hitting the boundary
                            # UP ARROW
                            | 38 => 
                                @scroll-lock = true
                                index = 
                                    | typeof @props.highlighted-uid == \undefined => 0
                                    | _ => -1 + @option-index-from-uid @props.highlighted-uid
                                result <~ @highlight-and-scroll-to-selectable-option index, -1
                                if !result
                                    @highlight-and-scroll-to-selectable-option (@props.options.length - 1), -1

                            # DOWN ARROW
                            | 40 => 
                                @scroll-lock = true
                                index = 
                                    | typeof @props.highlighted-uid == \undefined => 0
                                    | _ => 1 + @option-index-from-uid @props.highlighted-uid
                                result <~ @highlight-and-scroll-to-selectable-option index, 1
                                if !result
                                    @highlight-and-scroll-to-selectable-option 0, 1

                # LIST OF SELECTED VALUES (AFTER THE ANCHOR)
                render-selected-values [anchor-index + 1 til @props.values.length]
             
                if @props.values.length > 0

                    # RESET BUTTON
                    div do 
                        class-name: \react-selectize-reset
                        on-click: (e) ~>
                            do ~>
                                <~ @props.on-values-change []
                                <~ @props.on-search-change ""
                                @focus-on-input!
                            cancel-event e
                        \×

                # ARROW ICON 
                div do 
                    class-name: \react-selectize-arrow
                    on-mouse-down: (e) ~>
                        if @props.open
                            @on-open-change false, ~>
                        else
                            <~ @props.on-anchor-change last @props.values
                            <~ @on-open-change true
                        cancel-event e
        
            # (TETHERED / ANIMATED / SIMPLE) DROPDOWN
            @render-tethered-dropdown {anchor-index, dynamic-class-name} 

    # render-tethered-dropdown :: ComputedState -> ReactElement
    render-tethered-dropdown: (computed-state) ->
        if @props.tether 
            Tether do
                target: ~> find-DOM-node @refs.control
                options:
                    attachment: "top left"
                    target-attachment: "bottom left"
                    constraints:
                        * to: \scrollParent
                        ...
                @render-animated-dropdown computed-state

        else
            @render-animated-dropdown computed-state

    # render-animated-dropdown :: ComputedState -> ReactElement
    render-animated-dropdown: ({dynamic-class-name}:computed-state) ->
        if !!@props.transition-enter or !!@props.transition-leave
            ReactCSSTransitionGroup do 
                component: \div
                transition-name: \slide 
                transition-enter: @props.transition-enter
                transition-leave: @props.transition-leave
                transition-enter-timeout: @props.transition-enter-timeout
                transition-leave-timeout: @props.transition-leave-timeout
                class-name: "react-selectize-dropdown-container #{dynamic-class-name}"
                ref: \dropdown-container
                @render-dropdown computed-state

        else
            @render-dropdown computed-state

    # render-options :: [Item] -> Int -> [ReactEleent]
    render-options: (options, anchor-index) ->
        [0 til options.length] |> map (index) ~>
            option = options[index]
            uid = @props.uid option

            # OPTION WRAPPER 
            OptionWrapper do
                {
                    uid
                    ref: "option-#{@uid-to-string uid}"
                    key: @uid-to-string uid
                    item: option
                    highlight: @props.highlighted-uid `is-equal-to-object` uid
                    selectable: option?.selectable
                    on-mouse-move: ({current-target}) !~> @scroll-lock = false if @scroll-lock
                    on-mouse-out: !~> @props.on-highlighted-uid-change undefined if !@scroll-lock
                    render-item: @props.render-option
                } <<< 
                    switch 
                    | (typeof option?.selectable == \boolean) and !option.selectable => on-click: cancel-event
                    | _ => 
                        on-click: !~> @select-highlighted-uid anchor-index, ~>
                        on-mouse-over: ({current-target}) !~>  @props.on-highlighted-uid-change uid if !@scroll-lock

    # render-dropdown :: ComputedState -> ReactElement
    render-dropdown: ({anchor-index, dynamic-class-name}) ->
        if @props.open
            
            # DROPDOWN
            Div do 
                class-name: "react-selectize-dropdown #{dynamic-class-name}"
                key: \dropdown
                ref: \dropdown

                # on-height-change :: Number -> ()
                on-height-change: (height) !~> 
                    if @refs[\dropdown-container]
                        find-DOM-node @refs[\dropdown-container] .style.height = "#{height}px"

                # NO RESULT FOUND   
                if @props.options.length == 0
                    @props.render-no-results-found!
                
                else if @props?.groups?.length > 0

                    # convert [Group] to [{index: Int, group: Group, options: [Item]}]
                    groups = [0 til @props.groups.length] |> map (index) ~>  
                        {group-id}:group = @props.groups[index]
                        options = @props.options |> filter ~> (@props.group-id it) == group-id
                        {index, group, options}

                    # GROUPS
                    div class-name: "groups #{if !!@props.groups-as-columns then 'as-columns' else ''}",
                        groups 
                        |> filter (.options.length > 0)
                        |> map ({index, {group-id}:group, options}) ~>

                            # GROUP
                            div key: group-id,
                                @props.render-group-title index, group, options

                                # OPTIONS
                                div do 
                                    class-name: \options
                                    @render-options options, anchor-index

                else

                    # OPTIONS
                    @render-options @props.options, anchor-index

        else
            null

    # component-did-mount :: () -> ()
    component-did-mount: !->
        if @props.autofocus
            @focus!

    # component-did-update :: Props -> UIState -> ()
    component-did-update: (prev-props) !->

        # if the list of options opened then highlight the first option & focus on the search input
        if @props.open and !prev-props.open and @props.highlighted-uid == undefined
            @highlight-and-scroll-to-selectable-option (@props.first-option-index-to-highlight @props.options), 1
            @focus-on-input!

        # if the list of options was closed then reset highlighted-uid 
        @props.on-highlighted-uid-change undefined if !@props.open and prev-props.open

        # autosize the search input to its contents
        $search = (find-DOM-node @refs.search)
            ..style.width = "0px"
            ..style.width = "#{@props.autosize $search}px"

        # flip the dropdown if props.dropdown-direction is -1
        ref = @refs[if !!@refs[\dropdown-container] then \dropdown-container else \dropdown]
        if !!ref
            (find-DOM-node ref).style <<< 
                bottom: if @props.dropdown-direction == -1 then (find-DOM-node @refs.control).offset-height else ""

    # component-will-receive-props :: Props -> ()
    component-will-receive-props: (props) !->
        if (typeof @props.disabled == \undefined or @props.disabled == false) and 
           (typeof props.disabled != \undefined and props.disabled == true)
           @on-open-change false, ~>

    # option-index-from-uid :: (Eq e) => e -> Int
    option-index-from-uid: (uid) -> @props.options |> find-index ~> uid `is-equal-to-object` @props.uid it

    # close-dropdown :: (() -> ()) -> ()
    close-dropdown: (callback) !->
        <~ @on-open-change false
        @props.on-anchor-change do 
            last @props.values
            callback

    # blur :: () -> ()
    blur: !-> @refs.search.blur!

    # focus :: () -> ()
    focus: !-> @refs.search.focus!

    # move the cursor to the input field, without toggling the dropdown
    # focus-on-input :: () -> ()
    focus-on-input: !->
        input = find-DOM-node @refs.search
        if input != document.active-element
            @focus-lock = true

            # this triggers the DOM focus event on the input control, where we use @focus-lock to determine
            # if the event was triggered by external action or by invoking @focus-on-input method.
            input.focus!

    # highlight-and-scroll-to-option :: Int, (() -> ())? -> ()
    highlight-and-scroll-to-option: (index, callback = (->)) !->

        # update the focused option
        uid = @props.uid @props.options[index]
        <~ @props.on-highlighted-uid-change uid

        option-element? = find-DOM-node @refs?["option-#{@uid-to-string uid}"]

        if !!option-element
            parent-element = find-DOM-node @refs.dropdown
            option-height = option-element.offset-height - 1

            # in other words, if the option element is below the visible region
            if (option-element.offset-top - parent-element.scroll-top) >= parent-element.offset-height

                # scroll the option element into view, by scrolling the parent element downward by an amount equal to the
                # distance between the bottom-edge of the parent-element and the bottom-edge of the option element
                parent-element.scroll-top = option-element.offset-top - parent-element.offset-height + option-height

            # in other words, if the option element is above the visible region
            else if (option-element.offset-top - parent-element.scroll-top + option-height) <= 0

                # scroll the option element into view, by scrolling the parent element upward by an amount equal to the
                # distance between the top-edge of the option element and the top-edge of the parent element
                parent-element.scroll-top = option-element.offset-top

        callback!

    # highlight-and-scroll-to-selectable-option :: Int, Int, (Boolean -> ())? -> ()
    highlight-and-scroll-to-selectable-option: (index, direction, callback = (->)) !->

        # open the list of items
        <~ do ~> if !@props.open then (~> @on-open-change true, it) else (-> it!)

        # end recursion if the index violates the bounds
        if index < 0 or index >= @props.options.length
            <~ @props.on-highlighted-uid-change undefined
            callback false

        else

            # recurse until a selectable option is found while moving in the given direction
            option = @props?.options?[index]
            if typeof option?.selectable == \boolean and !option.selectable
                @highlight-and-scroll-to-selectable-option index + direction, direction, callback

            # highlight the option found & end the recursion
            else
                <~ @highlight-and-scroll-to-option index
                callback true

    # is-equal-to-object :: Item -> Item -> Boolean
    is-equal-to-object: --> (@props.uid &0) `is-equal-to-object` @props.uid &1

    # on-open-change :: Boolean -> (() -> ()) -> ()
    on-open-change: (open, callback) ->
        @props.on-open-change do 
            if @props.disabled then false else open
            callback

    # select-highlighted-uid :: Int -> ()
    select-highlighted-uid: (anchor-index, callback) !->
        # return if there isn't any highlighted / focused option
        return callback! if @props.highlighted-uid == undefined
        
        # sanity check
        index = @option-index-from-uid @props.highlighted-uid
        return callback! if typeof index != \number

        option = @props.options[index]

        # values = (values behind & including the anchor) + highlighted option + (values ahead of the anchor)
        <~ @props.on-values-change do
            (map (~> @props.values[it]), [0 to anchor-index]) ++ 
            [option] ++ 
            (map (~> @props.values[it]), [anchor-index + 1 til @props.values.length])

        value = find (~> it `@is-equal-to-object` option), @props.values
        return callback! if !value
        
        # if the user did what we asked, then clear the search and move the anchor ahead of the selected value
        <~ @props.on-search-change ""
        <~ @props.on-anchor-change value
        return callback value if !@props.open
        
        # highlight the next selectable option
        result <~ @highlight-and-scroll-to-selectable-option index, 1
        return callback value if !!result
        
        # if there are no highlightable/selectable options (then close the dropdown)
        result <~ @highlight-and-scroll-to-selectable-option do 
            @props.first-option-index-to-highlight @props.options
            1
        if !result 
            <~ @on-open-change false
            callback value
        else
            callback value
    
    # uid-to-string :: () -> String, only used for the key prop (required by react render), & for refs
    uid-to-string: (uid) -> (if typeof uid == \object then JSON.stringify else id) uid