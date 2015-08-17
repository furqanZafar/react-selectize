{filter, find, initial, last, map, partition, reject, reverse, sort-by} = require \prelude-ls
{clamp, find-all, partition-string} = require \prelude-extension
{DOM:{div, input, span}}:React = require \react

module.exports = React.create-class do

    display-name: \ReactSelectize

    focused-option: -1

    # locks allow to temprorily block default event processing
    focus-lock: false
    scroll-lock: false

    # get-default-props :: a -> Props
    get-default-props: ->
        close-on-select: true
        disabled: false
        # max-values: 1
        render-no-results-found: -> # a -> ReactElement
        on-blur: ((values) !->) # [Item] -> Void
        on-search-change: ((search, callback) !-> ) # String -> (a -> Void) -> Void
        on-values-change: ((values, callback) !->) # [Item] -> (a -> Void) -> Void
        options: [] # [Item]        
        render-option: ((index, focused, option) ->) # Int -> Boolean -> Item -> ReactElement
        render-value: ((index, value) ->) # Int -> Item -> ReactElement
        # restore-on-backspace: ((value) -> ) # Item -> String
        search: ""
        style: {}
        values: [] # [Item]

    # render :: a -> ReactElement
    render: ->

        show-options = switch
            | @props.disabled => false
            | !@is-below-limit! => false
            | _ => @state.open

        # MULTISELECT
        div do 
            class-name: "multi-select #{if @props.disabled then 'disabled' else ''} #{if show-options then 'open' else ''}"
            style: @props.style
            on-click: ~>
                @focus!
                <~ @set-state open: (!@props.disabled and @is-below-limit!)
                @highlight-selectable-option 0, 1 if @state.open

            # CONTROL
            div do 
                class-name: \control
                key: \control

                # PLACEHOLDER TEXT
                if @props.search.length == 0 and @props.values.length == 0
                    div do 
                        class-name: \placeholder
                        @props.placeholder

                # LIST OF SELECTED VALUES
                [0 til @props.values.length] |> map (index) ~> @props.render-value index, @props.values[index]
                    
                # SEARCH INPUT BOX
                input do
                    disabled: @props.disabled
                    ref: \search
                    type: \text
                    value: @props.search
                    on-change: switch
                        | @is-below-limit! => ({current-target:{value}}) ~>
                            <~ @props.on-search-change value
                            @highlight-selectable-option 0, 1

                        # disable the text entry if the user has selected all the availabe options
                        | _ => (->)

                    on-focus: !~> 
                        if !!@focus-lock 
                            @focus-lock = false
                        else
                            <~ @set-state open: (!@props.disabled and @is-below-limit!)
                            @highlight-selectable-option 0, 1 if @state.open

                    on-key-down: (e) ~>
                        
                        # always handle the tab and the backspace key
                        switch e.which

                        # TAB
                        | 9 =>
                            <~ @set-state open: false
                            @props.on-blur @props.values

                        # BACKSPACE
                        | 8 => 
                            return if @props.search.length > 0

                            # restore on backspace functionality
                            do ~>
                                value-to-remove = last @props.values
                                <~ @props.on-values-change (initial @props.values) ? []
                                if !!@props.restore-on-backspace and !!value-to-remove
                                    <~ @props.on-search-change @props.restore-on-backspace value-to-remove
                                    @highlight-selectable-option 0, 1

                            e.prevent-default!
                            e.stop-propagation!

                        # ESCAPE
                        | 27 =>
                            <~ do ~>
                                if @state.open
                                    @refs?["option-#{@focused-option}"]?.getDOMNode!?.class-name = \option-wrapper
                                    @focused-option = -1
                                    @set-state open: false
                                    ~> it!
                                else
                                    ~> @props.on-values-change [], it
                            <~ @props.on-search-change ""
                            @focus!

                        # no need to process or block any keys if we ran out of options
                        return if !@is-below-limit! or @props.options.length == 0
                            
                        # ENTER
                        if e.which == 13 and @state.open
                            <~ @props.on-values-change @props.values ++ [@props.options?[@focused-option]]
                            <~ @props.on-search-change ""
                            open = @state.open and !@props.close-on-select
                            <~ do ~> if open == @state.open then (~> it!) else (~> @set-state {open}, it)
                            if @state.open
                                @highlight-selectable-option 0, 1
                            else
                                @focused-option = -1

                        else

                            switch e.which

                            # UP ARROW
                            | 38 => @highlight-selectable-option (clamp @focused-option - 1, 0, @props.options.length - 1), -1

                            # DOWN ARROW
                            | 40 => @highlight-selectable-option (clamp @focused-option + 1, 0, @props.options.length - 1), 1

                            # REST (we don't need to process or block rest of the keys)
                            | _ => return

                        e.prevent-default!
                        e.stop-propagation!

    
                # RESET BUTTON
                div do 
                    class-name: \reset
                    on-click: (e) ~>
                        do ~>
                            <~ @props.on-values-change []
                            <~ @props.on-search-change ""
                            @focus!
                        e.prevent-default!
                        e.stop-propagation!
                    \×

                # ARROW ICON
                div {class-name: \arrow}, null

            if @state.open
                
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
                                    on-mouse-move: !~> @scroll-lock = false
                                    on-mouse-over: ~>
                                        return if @scroll-lock
                                        @refs?["option-#{@focused-option}"]?.getDOMNode!?.class-name = \option-wrapper
                                        @focused-option = -1
                                } <<< 
                                    switch 
                                    | (typeof option?.selectable == \boolean) and !option.selectable => 
                                        on-click: (e) ~>
                                            e.prevent-default!
                                            e.stop-propagation!
                                    | _ => 
                                        on-click: (e) ~>
                                            do ~>
                                                <~ @props.on-values-change @props.values ++ [@props.options?[index]]
                                                <~ @props.on-search-change ""
                                                @focus!
                                                do ~>
                                                    open = @state.open and !@props.close-on-select

                                                    # an optimization (avoid unwanted calls to render function)
                                                    if open == @state.open then (~> it!) else (~> @set-state {open}, it)

                                            e.prevent-default!
                                            e.stop-propagation!
                                        on-mouse-over: ({current-target}) ~>
                                            return if @scroll-lock
                                            @refs?["option-#{@focused-option}"]?.getDOMNode!?.class-name = \option-wrapper
                                            current-target.class-name = "option-wrapper focused"
                                            @focused-option = index

                                # OPTION
                                @props.render-option index, option


    # get-initial-state :: a -> UIState
    get-initial-state: -> open: false

    # autosize search input width
    # component-did-update :: a -> Void
    component-did-update: !->
        $search = @refs.search.get-DOM-node!
            ..style.width = 0
            ..style.width = $search.scroll-width

    component-will-receive-props: (props) !->  @set-state open: false if @state.open and (props.disabled or !@is-below-limit props)

    # focuses on the cursor search input
    # focus :: a -> Void
    focus: !-> 
        @focus-lock = true
        @refs.search.getDOMNode!.focus!

    # foucs-option :: Int -> Void
    highlight-option: (index) !->

        # block mouse events from firing while adjusting scroll position 
        @scroll-lock = true        

        # lowlight the previous option
        @refs?["option-#{@focused-option}"]?.getDOMNode!?.class-name = \option-wrapper

        # find the next option to highlight
        @focused-option = index

        # get a refrence to DOM node of the element to highlight
        {parent-element}:option-element? = @refs?["option-#{@focused-option}"]?.getDOMNode!
        return if !option-element

        # highlight the option
        option-element.class-name = 'option-wrapper focused'

        # scroll to the option
        option-height = option-element.offset-height - 1

        if (option-element.offset-top - parent-element.scroll-top) >= parent-element.offset-height
            parent-element.scroll-top = option-element.offset-top - parent-element.offset-height + option-height

        else if (option-element.offset-top - parent-element.scroll-top + option-height) <= 0
            parent-element.scroll-top = option-element.offset-top

    # highlight-selectable-option :: Int -> Int -> Void
    highlight-selectable-option: (index, direction) !->        

        # open the list of items
        <~ do ~>
            if !@state.open 
                ~> @set-state open: true, it
            else
                -> it!

        # end recursion if the index violates the bounds
        return if index < 0 or index >= @props.options.length

        # recurse until a selectable option is found while moving in the given direction
        option = @props?.options?[index]
        if typeof option?.selectable == \boolean and !option.selectable
            @highlight-selectable-option index + direction, direction

        # highlight the option found & end the recursion
        else
            @highlight-option index

    # is-below-limit :: Props -> boolean
    is-below-limit: (props) -> 
        {max-values, values}? = props or @props
        (typeof max-values == \undefined) or values.length < max-values