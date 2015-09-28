{each, filter, find, find-index, initial, last, map, obj-to-pairs, partition, reject, reverse, sort-by, sum} = require \prelude-ls
{clamp, is-equal-to-object} = require \prelude-extension
{DOM:{div, input, span}, create-class, create-factory, find-DOM-node}:React = require \react

# cancel-event :: Event -> Void
cancel-event = (e) !->
    e.prevent-default!
    e.stop-propagation!

# wrapper classes are used for optimizing performance
OptionWrapper = create-factory create-class do 

    # render :: a -> ReactElement
    render: ->
        div do
            class-name: "option-wrapper #{if !!@props.highlight then 'highlight' else ''}"
            on-click: @props.on-click
            on-mouse-move: @props.on-mouse-move
            on-mouse-out: @props.on-mouse-out
            on-mouse-over: @props.on-mouse-over
            @props.render-item @props.item

    # should-component-update :: Props -> Boolean
    should-component-update: (next-props) ->
        (next-props?.uid != @props?.uid) or (next-props?.highlight != @props?.highlight)

ValueWrapper = create-factory create-class do 

    # render :: a -> ReactElement
    render: ->
        div do 
            class-name: \value-wrapper
            @props.render-item @props.item

    # should-component-update :: Props -> Boolean
    should-component-update: (next-props) ->
        next-props?.uid != @props?.uid

module.exports = create-class do

    display-name: \ReactSelectize

    # used to figure out if the focus event was triggered by external action or by @focus!
    focus-lock: false

    # used to block default behaviour of option.mouseover when triggered by scrolling using arrow keys
    scroll-lock: false

    # get-default-props :: a -> Props
    get-default-props: ->
        anchor: null
        # autosize :: InputElement -> Int
        autosize: ($search) -> 

            # modern browsers
            if $search.scroll-width > 0
                $search.style.width = "#{2 + $search.scroll-width}px"

            # IE / Edge
            else
                $input = document.create-element \div
                    ..innerHTML = $search.value

                # copy all the styles of the search input 
                (if !!$search.current-style then $search.current-style else (document.default-view ? window .get-computed-style $search))
                    |> obj-to-pairs
                    |> each ([key, value]) -> $input.style[key] = value
                    |> -> $input.style.width = ""

                # add a new input element to document.body and measure the text width
                document.body.append-child $input
                $search.style.width = "#{4 + $input.client-width}px"
                document.body.remove-child $input

        # class-name :: String
        disabled: false
        dropdown-direction: 1
        first-option-index-to-highlight: (options) -> 0
        group-id: (.group-id) # Item -> a
        # groups :: [Group]
        groups-as-columns: false
        highlighted-uid: undefined
        on-anchor-change: ((anchor) ->) # Item -> Void
        on-blur: ((values, reason) !->) # [Item] -> String -> Void
        on-focus: ((values, reason) !->) # [Item] -> String -> Void
        on-highlighted-uid-change: ((uid, callback) !-> ) # (Eq e) => e -> (a -> Void) -> Void
        on-open-change: ((open, callback) !->) # Boolean -> (a -> Void) -> Void
        on-search-change: ((search, callback) !-> ) # String -> (a -> Void) -> Void
        on-values-change: ((values, callback) !->) # [Item] -> (a -> Void) -> Void
        open: false
        options: [] # [Item]
        # render-no-results-found :: a -> ReactElement
        render-no-results-found: -> div class-name: \no-results-found, "No results found"
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
        search: ""
        style: {}
        uid: (.value) # (Eq e) => Item -> e
        values: [] # [Item]

    # render :: a -> ReactElement
    render: ->
        anchor-index = 
            | (typeof @props.anchor == \undefined) or @props.anchor == null => -1
            | _ => (find-index (~> it `@is-equal-to-object` @props.anchor), @props.values) ? @props.values.length - 1        

        # render-selected-values :: [Int] -> [ValueWrapper]
        render-selected-values = ~> it |> map (index) ~> 
            item = @props.values[index]
            uid = @props.uid item
            ValueWrapper {uid, key: uid, item, render-item: @props.render-value}

        # REACT SELECTIZE
        div do 
            class-name: "react-selectize" + 
                (if !!@props.class-name then " #{@props.class-name}" else "") + 
                "#{if @props.disabled then ' disabled' else ''}#{if @props.open then ' open' else ''}#{if @props.dropdown-direction == -1 then ' flipped' else ''}"
            style: @props.style
            
            # CONTROL
            div do 
                class-name: \control
                ref: \control
                on-click: ~>
                    <~ @props.on-anchor-change last @props.values
                    <~ @props.on-open-change true
                    @focus!
                
                # PLACEHOLDER TEXT
                if @props.search.length == 0 and @props.values.length == 0
                    div do 
                        class-name: \placeholder
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
                            if !(@highlight-and-scroll-to-selectable-option (@props.first-option-index-to-highlight @props.options), 1)
                                @props.on-highlighted-uid-change undefined

                    # show the list of options (noop if caused by invocation of @focus function)
                    on-focus: !~>
                        result <~ do ~> (callback) ~> if !!@focus-lock then callback @focus-lock = false else @props.on-open-change true, -> callback true
                        @props.on-focus @props.values, if !!result then \event else \focus

                    on-key-down: (e) ~>

                        # always handle the tab, backspace & escape keys
                        switch e.which

                        # TAB
                        | 9 =>
                            <~ @props.on-open-change false
                            <~ @props.on-anchor-change last @props.values
                            @props.on-blur @props.values, \tab

                        # BACKSPACE
                        | 8 => 
                            
                            return if @props.search.length > 0 or anchor-index == -1

                            do ~>
                                # compute the next-anchor
                                anchor-index-on-remove = anchor-index
                                next-anchor = if (anchor-index - 1) < 0 then undefined else @props.values[anchor-index - 1]

                                value-to-remove = @props.values[anchor-index]
                                <~ @props.on-values-change (reject (~> it `@is-equal-to-object` value-to-remove), @props.values) ? []

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
                                    @highlight-and-scroll-to-selectable-option (@props.first-option-index-to-highlight @props.options), 1

                                # change the anchor iff the consumer removed the requested value & the predicted next-anchor is still present
                                if !!result and 
                                    anchor-index == anchor-index-on-remove and 
                                    ((typeof next-anchor == \undefined) or !!(find (~> it `@is-equal-to-object` next-anchor), @props.values))
                                        <~ @props.on-anchor-change next-anchor

                            cancel-event e

                        # ESCAPE
                        | 27 =>
                            # first hit closes the list of options, second hit will reset the selected values
                            <~ do ~> if @props.open then (~> @props.on-open-change false, it) else (~> @props.on-values-change [], it)
                            <~ @props.on-search-change ""
                            @focus!

                        if @props.search.length == 0
                            
                            switch e.which

                            # LEFT ARROW
                            | 37 =>
                                @props.on-anchor-change do
                                   if ((anchor-index - 1) < 0 or e.meta-key) then undefined else @props.values[clamp (anchor-index - 1), 0, (@props.values.length - 1)]
                                   (->)

                            # RIGHT ARROW
                            | 39 =>
                                @props.on-anchor-change do
                                   if e.meta-key then last @props.values else @props.values[clamp (anchor-index + 1), 0, (@props.values.length - 1)]
                                   (->)

                        # no need to process or block any keys if we ran out of options
                        return if @props.options.length == 0
                            
                        # ENTER
                        if e.which == 13 and @props.open
                            @select-highlighted-uid anchor-index

                        else
                            switch e.which

                            # UP ARROW
                            | 38 => 
                                @scroll-lock = true
                                @highlight-and-scroll-to-selectable-option (@option-index-from-uid @props.highlighted-uid) - 1, -1

                            # DOWN ARROW
                            | 40 => 
                                @scroll-lock = true
                                @highlight-and-scroll-to-selectable-option ((@option-index-from-uid @props.highlighted-uid) ? -1) + 1, 1

                            # REST (we don't need to process or block rest of the keys)
                            | _ => return

                        cancel-event e
                
                # LIST OF SELECTED VALUES (AFTER THE ANCHOR)
                render-selected-values [anchor-index + 1 til @props.values.length]
                 
                # RESET BUTTON
                div do 
                    class-name: \reset
                    on-click: (e) ~>
                        do ~>
                            <~ @props.on-values-change []
                            <~ @props.on-search-change ""
                            @focus!
                        cancel-event e
                    \×

                # ARROW ICON 
                div do 
                    class-name: \arrow
                    on-click: (e) ~>
                        if @props.open 
                            @props.on-open-change false
                            @props.on-blur @props.values, \arrow-click
                        else
                            <~ @props.on-anchor-change last @props.values
                            <~ @props.on-open-change true
                            @focus!
                        cancel-event e

            # DROPDOWN
            if @props.open
                
                # render-options :: [Item] -> Int -> [ReactEleent]
                render-options = (options, index-offset) ~>
                    [0 til options.length] |> map (index) ~>
                        option = options[index]
                        uid = @props.uid option

                        # OPTION WRAPPER 
                        OptionWrapper do
                            {
                                uid
                                ref: "option-#{uid}"
                                key: uid
                                item: option
                                highlight: @props.highlighted-uid == uid
                                on-mouse-move: ({current-target}) !~> @scroll-lock = false if @scroll-lock
                                on-mouse-out: !~> @props.on-highlighted-uid-change undefined if !@scroll-lock
                                render-item: @props.render-option
                            } <<< 
                                switch 
                                | (typeof option?.selectable == \boolean) and !option.selectable => on-click: cancel-event
                                | _ => 
                                    on-click: (e) !~> @select-highlighted-uid anchor-index
                                    on-mouse-over: ({current-target}) !~>  @props.on-highlighted-uid-change uid if !@scroll-lock

                div do 
                    class-name: \dropdown
                    ref: \dropdown

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
                                    offset = [0 til index]
                                        |> map -> groups[it].options.length
                                        |> sum
                                    div key: group-id,
                                        @props.render-group-title index, group, options
                                        div class-name: \options,
                                            render-options options, offset

                    else
                        render-options @props.options, 0

    # component-did-mount :: a -> Void
    component-did-mount: !->
        root-node = find-DOM-node @
        @external-click-listener = ({target}) ~>
            dom-node-contains = (element) ~>
                return false if (typeof element == \undefined) or element == null
                return true if element == root-node
                dom-node-contains element.parent-element
            if !(dom-node-contains target)
                @props.on-open-change false
                @props.on-blur @props.values, \click
        document.add-event-listener \click, @external-click-listener, true

    # component-will-unmount :: a -> Void
    component-will-unmount: !->
        document.remove-event-listener \click, @external-click-listener, true

    # component-did-update :: Props -> UIState -> Void
    component-did-update: (prev-props, prev-state) !->

        # if the list of options opened then highlight the first option & focus on the search input
        if @props.open and !prev-props.open and @props.highlighted-uid == undefined
            @highlight-and-scroll-to-selectable-option (@props.first-option-index-to-highlight @props.options), 1
            @focus!

        # if the list of options was closed then reset the highlighted-uid to -1
        @props.on-highlighted-uid-change undefined if !@props.open and prev-props.open

        # autosize the search input to its contents
        $search = (find-DOM-node @refs.search)
            ..style.width = "0px"
            ..style.width = "#{@props.autosize $search}px"

        if !!@refs.dropdown
            (find-DOM-node @refs.dropdown).style.bottom = if @props.dropdown-direction == -1 then (find-DOM-node @refs.control).offset-height else ""

    # component-will-receive-props :: Props -> Void
    component-will-receive-props: (props) !->
        if (typeof @props.disabled == \undefined or @props.disabled == false) and (typeof props.disabled != \undefined and props.disabled == true)
           @props.on-open-change false

    # option-index-from-uid :: (Eq e) => e -> Int
    option-index-from-uid: (uid) -> @props.options |> find-index ~> uid == @props.uid it

    # blur :: a -> Void
    blur: !-> 
        (find-DOM-node @refs.search).blur!
        @props.on-blur @props.values, \blur

    # focus on search input if it doesn't already have it
    # focus :: a -> Void
    focus: !->
        if (find-DOM-node @refs.search) != document.active-element
            @focus-lock = true
            (find-DOM-node @refs.search).focus!

    # highlight-and-scroll-to-option :: Int -> Void
    highlight-and-scroll-to-option: (index) !->
        uid = @props.uid @props.options[index]
        <~ @props.on-highlighted-uid-change uid
        option-element? = find-DOM-node @refs?["option-#{uid}"]
        parent-element = find-DOM-node @refs.dropdown
        if !!option-element
            option-height = option-element.offset-height - 1
            if (option-element.offset-top - parent-element.scroll-top) >= parent-element.offset-height
                parent-element.scroll-top = option-element.offset-top - parent-element.offset-height + option-height
            else if (option-element.offset-top - parent-element.scroll-top + option-height) <= 0
                parent-element.scroll-top = option-element.offset-top

    # highlight-and-scroll-to-selectable-option :: Int -> Int -> Boolean
    highlight-and-scroll-to-selectable-option: (index, direction) ->

        # open the list of items
        <~ do ~> if !@props.open then (~> @props.on-open-change true, it) else (-> it!)

        # end recursion if the index violates the bounds
        if index < 0 or index >= @props.options.length
            false

        else

            # recurse until a selectable option is found while moving in the given direction
            option = @props?.options?[index]
            if typeof option?.selectable == \boolean and !option.selectable
                @highlight-and-scroll-to-selectable-option index + direction, direction

            # highlight the option found & end the recursion
            else
                @highlight-and-scroll-to-option index
                true

    # is-equal-to-object :: Item -> Item -> Boolean
    is-equal-to-object: --> (@props.uid &0) `is-equal-to-object` @props.uid &1

    # select-highlighted-uid :: Int -> Void
    select-highlighted-uid: (anchor-index) !->
        return if @props.highlighted-uid == undefined
        
        index = @option-index-from-uid @props.highlighted-uid
        return if typeof index != \number

        option = @props.options[index]

        # values = (values behind & including the anchor) + highlighted option + (values ahead of the anchor)
        <~ @props.on-values-change do
            (map (~> @props.values[it]), [0 to anchor-index]) ++ 
            [option] ++ 
            (map (~> @props.values[it]), [anchor-index + 1 til @props.values.length])

        value = find (~> it `@is-equal-to-object` option), @props.values

        # if the consumer did what we asked, then clear the search and move the anchor ahead of the selected value
        if !!value
            <~ @props.on-search-change ""
            <~ @props.on-anchor-change value

            # highlight the next selectable option, if available & the dropdown is still open
            if !!@props.open
                if !!@props.options?[index]
                    @props.on-highlighted-uid-change @props.uid @props.options[index]
                else
                    @highlight-and-scroll-to-selectable-option (@props.first-option-index-to-highlight @props.options), 1
