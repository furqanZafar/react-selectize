{filter, find, find-index, initial, last, map, partition, reject, reverse, sort-by} = require \prelude-ls
{clamp, is-equal-to-object} = require \prelude-extension
{DOM:{div, input, span}}:React = require \react

# cancel-event :: Event -> Void
cancel-event = (e) !->
    e.prevent-default!
    e.stop-propagation!

module.exports = React.create-class do

    display-name: \ReactSelectize

    # performance optimization (minimizes calls to render function)
    highlighted-option: -1

    # used to figure out if the focus event was triggered by external action or by @focus!
    focus-lock: false

    # used to block the browser option.mouseover when scrolling is triggered by arrow keys
    scroll-lock: false

    # get-default-props :: a -> Props
    get-default-props: ->
        anchor: null
        class-name: ''
        disabled: false
        first-option-index-to-highlight: (options) -> 0
        on-anchor-change: ((anchor) ->) # Item -> Void
        on-blur: ((values, reason) !->) # [Item] -> String -> Void
        on-focus: ((values, reason) !->) # [Item] -> String -> Void
        on-open-change: ((open, callback) !->) # Boolean -> (a -> Void) -> Void
        on-search-change: ((search, callback) !-> ) # String -> (a -> Void) -> Void
        on-values-change: ((values, callback) !->) # [Item] -> (a -> Void) -> Void
        open: false
        options: [] # [Item]
        # render-no-results-found :: a -> ReactElement
        render-no-results-found: -> div class-name: \no-results-found, "No results found"
        # render-option :: Int -> Item -> ReactElement
        render-option: (index, {label, new-option, selectable}?) ->
            is-selectable = (typeof selectable == \undefined) or selectable
            div do 
                class-name: "simple-option #{if is-selectable then '' else 'not-selectable'}"
                key: index
                span null, if !!new-option then "Add #{label} ..." else label
        # render-value :: Int -> Item -> ReactElement
        render-value: (index, {label}) ->
            div do 
                class-name: \simple-value
                key: index
                span null, label
        # restore-on-backspace: ((value) -> ) # Item -> String
        search: ""
        style: {}
        values: [] # [Item]

    # render :: a -> ReactElement
    render: ->
        anchor-index = 
            | (typeof @props.anchor == \undefined) or @props.anchor == null => -1
            | _ => (find-index (~> it `is-equal-to-object` @props.anchor), @props.values) ? @props.values.length - 1

        # MULTISELECT
        div do 
            class-name: "react-selectize #{@props.class-name} #{if @props.disabled then 'disabled' else ''} #{if @props.open then 'open' else ''}"
            style: @props.style
            on-click: ~>
                <~ @props.on-anchor-change last @props.values
                <~ @props.on-open-change true
                @focus!

            # CONTROL
            div do 
                class-name: \control
                key: \control

                # PLACEHOLDER TEXT
                if @props.search.length == 0 and @props.values.length == 0
                    div do 
                        class-name: \placeholder
                        @props.placeholder

                # LIST OF SELECTED VALUES (BEFORE & INCLUDING THE ANCHOR)
                [0 to anchor-index] |> map (index) ~> @props.render-value index, @props.values[index]

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
                                @lowlight-option!

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
                                <~ @props.on-values-change (reject (-> it `is-equal-to-object` value-to-remove), @props.values) ? []

                                # result is true if the user removed the value we requested him to remove
                                result <~ do ~> (callback) ~>

                                    if typeof find (~> it `is-equal-to-object` value-to-remove), @props.values == \undefined

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
                                    ((typeof next-anchor == \undefined) or !!(find (-> it `is-equal-to-object` next-anchor), @props.values))
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
                            <~ @select-highlighted-option anchor-index
                            if @props.open and !(@highlight-and-scroll-to-selectable-option @highlighted-option, 1)
                                if !(@highlight-and-scroll-to-selectable-option 0, 1)
                                    @lowlight-option!

                        else
                            switch e.which

                            # UP ARROW
                            | 38 => 
                                @scroll-lock = true
                                @highlight-and-scroll-to-selectable-option @highlighted-option - 1, -1

                            # DOWN ARROW
                            | 40 => 
                                @scroll-lock = true
                                @highlight-and-scroll-to-selectable-option @highlighted-option + 1, 1

                            # REST (we don't need to process or block rest of the keys)
                            | _ => return

                        cancel-event e
                
                # LIST OF SELECTED VALUES (AFTER THE ANCHOR)
                [anchor-index + 1 til @props.values.length] |> map (index) ~> @props.render-value index, @props.values[index]
    
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
                div {class-name: \arrow}, null

            if @props.open
                
                div do 
                    class-name: \options
                    
                    # NO RESULT FOUND   
                    if @props.options.length == 0
                        @props.render-no-results-found!
                    
                    # OPTIONS
                    else
                        [0 til @props.options.length] |> map (index) ~>

                            option = @props.options[index]

                            # OPTION WRAPPER 
                            div do
                                {
                                    class-name: \option-wrapper
                                    ref: "option-#{index}"
                                    key: "#{index}"
                                    on-mouse-move: ({current-target}) !~> @scroll-lock = false if @scroll-lock
                                    on-mouse-out: !~> @lowlight-option! if !@scroll-lock
                                } <<< 
                                    switch 
                                    | (typeof option?.selectable == \boolean) and !option.selectable => on-click: cancel-event
                                    | _ => 
                                        on-click: (e) !~>
                                            @select-highlighted-option anchor-index, (->)
                                            cancel-event e
                                        on-mouse-over: ({current-target}) !~> @highlight-option index if !@scroll-lock

                                # OPTION
                                @props.render-option index, option

    # component-did-mount :: a -> Void
    component-did-mount: !->
        document.add-event-listener do 
            \click
            ({target}) ~>
                dom-node-contains = (element) ~>
                    return false if (typeof element == \undefined) or element == null
                    return true if element == @get-DOM-node!
                    dom-node-contains element.parent-element
                if !(dom-node-contains target)
                    @props.on-open-change false
                    @props.on-blur @props.values, \click
            true

    # autosize search input width
    # component-did-update :: Props -> UIState -> Void
    component-did-update: (prev-props, prev-state) ->

        # if the list of options opened then highlight the first option & focus on the serach input
        if @props.open and !prev-props.open and @highlighted-option = -1
            @highlight-and-scroll-to-selectable-option (@props.first-option-index-to-highlight @props.options), 1
            @focus!

        # if the list of options was closed then reset the highlighted-option to -1
        @highlighted-option = -1 if !@props.open and prev-props.open

        # autosize the search input to its contents
        $search = @refs.search.get-DOM-node!
            ..style.width = 0
            ..style.width = $search.scroll-width

    # component-will-receive-props :: Props -> Void
    component-will-receive-props: (props) !->
        if (typeof @props.disabled == \undefined or @props.disabled == false) and (typeof props.disabled != \undefined and props.disabled == true)
           @props.on-open-change false

    # focus on search input if it doesn't already have it
    # focus :: a -> Void
    focus: !-> 
        if @refs.search.getDOMNode! != document.active-element
            @focus-lock = true
            @refs.search.getDOMNode!.focus!

    # blur :: a -> Void
    blur: !-> 
        @refs.search.getDOMNode!.blur!
        @props.on-blur @props.values, \blur

    # highlight-option :: Int -> DOMElement
    highlight-option: (index) ->
        @lowlight-option!
        @highlighted-option = index
        option-element = @refs?["option-#{index}"]?.getDOMNode!
            ..class-name = "option-wrapper focused"
        option-element
    
    # lowlight-option :: a -> Void
    lowlight-option: !->
        @refs?["option-#{@highlighted-option}"]?.getDOMNode!?.class-name = \option-wrapper
        @highlighted-option = -1

    # highlight-and-scroll-to-option :: Int -> Void
    highlight-and-scroll-to-option: (index) !->

        {parent-element}:option-element? = @highlight-option index
        
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

    # select-highlighted-option :: Int -> (a -> Void) -> Void
    select-highlighted-option: (anchor-index, callback) !->
        if @highlighted-option != -1

            option = @props.options?[@highlighted-option]

            # values = (values behind & including the anchor) + highlighted option + (values ahead of the anchor)
            <~ @props.on-values-change do
                (map (~> @props.values[it]), [0 to anchor-index]) ++ 
                [option] ++ 
                map (~> @props.values[it]), [anchor-index + 1 til @props.values.length]

            value = find (-> it `is-equal-to-object` option), @props.values

            # if the consumer did what we asked, then clear the search and move the anchor ahead of the selected value
            if !!value
                <~ @props.on-search-change ""
                @props.on-anchor-change value, callback

            else
                callback!