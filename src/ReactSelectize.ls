{filter, find, initial, last, map, partition, reject, reverse, sort-by} = require \prelude-ls
{clamp, find-all, partition-string} = require \prelude-extension
{DOM:{div, input, span}}:React = require \react

module.exports = React.create-class do

    display-name: \ReactSelectize

    # get-default-props :: a -> Props
    get-default-props: ->
        disabled: false
        # max-values: 1
        on-blur: ((values) !->) # [Item] -> Void
        on-search-change: ((search) !-> ) # String -> Void
        on-values-change: ((values) !->) # [Item] -> Void
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
                @set-state open: if @state.open then false else true
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
                            @props.on-search-change value
                            @set-state focused-option: 0, open: true

                        # disable the text entry if the user has selected all the availabe options
                        | _ => (->)

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
                            
                            if !!@props.restore-on-backspace
                                @set-state do 
                                    focused-option: 0
                                    open: true
                                @props.on-search-change @props.restore-on-backspace last @props.values
                            else
                                @set-state open: false

                            @props.on-values-change initial @props.values

                            e.prevent-default!
                            e.stop-propagation!

                        # no need to process or block any keys if we ran out of options
                        if @props.options.length == 0
                            return

                        else

                            switch e.which

                            # ENTER
                            | 13 => 
                                @select-option @state.focused-option
                                @set-state do 
                                    focused-option: -1
                                    open: false
                                    search: ''

                            # ESC
                            | 27 =>
                                if @state.open
                                    @set-state open: false
                                else
                                    @reset!
                                @clear-and-foucs!

                            # UP ARROW
                            | 38 => @focus-adjacent-option -1

                            # DOWN ARROW
                            | 40 => @focus-adjacent-option 1

                            # REST (we don't need to process or block rest of the keys)
                            | _ => return

                            e.prevent-default!
                            e.stop-propagation!

    
                # RESET BUTTON
                div do 
                    class-name: \reset
                    on-click: (e) ~>
                        @reset!
                        @clear-and-foucs!
                        e.prevent-default!
                        e.stop-propagation!
                    \×

                # ARROW ICON
                div {class-name: \arrow}, null

            # LIST OF OPTIONS
            if show-options

                if @props.options.length == 0
                    div do 
                        null
                        div do 
                            null
                            'Out of options ¯\_(ツ)_/¯'

                else
                    div do 
                        class-name: \options
                        [0 til @props.options.length] |> map (index) ~>
                            
                            # OPTION WRAPPER 
                            div do
                                ref: "option-#{index}"
                                key: "#{index}"
                                on-click: (e) ~>
                                    @set-state {open: false}, ~>
                                        @select-option index
                                        @clear-and-foucs!
                                    e.prevent-default!
                                    e.stop-propagation!
                                on-mouse-over: ~> @set-state focused-option: index
                                on-mouse-out: ~> @set-state focused-option: -1

                                # OPTION
                                @props.render-option index, index == @state.focused-option, @props.options[index]


    # get-initial-state :: a -> UIState
    get-initial-state: -> focused-option: 0, open: false

    # component-did-update :: a -> Void
    component-did-update: !->

        # scroll to the currently focused item
        do ~>
            return if @state.focused-option == -1

            {parent-element}:option-element? = @?.refs?["option-#{@state.focused-option}"]?.getDOMNode!
            return if !option-element

            option-height = option-element.offset-height - 1

            if (option-element.offset-top - parent-element.scroll-top) > parent-element.offset-height
                parent-element.scroll-top = option-element.offset-top - parent-element.offset-height + option-height

            else if (option-element.offset-top - parent-element.scroll-top + option-height) < 0
                parent-element.scroll-top = option-element.offset-top   

        # autosize search input width
        do ~>
            $search = @refs.search.get-DOM-node!
                ..style.width = 0
                ..style.width = $search.scroll-width

    # clear-and-focus :: a -> Void    
    clear-and-foucs: !->
        @set-state search: ''
        @focus!    

    # focuses on the cursor search input
    # focus :: a -> Void
    focus: !-> @refs.search.getDOMNode!.focus!

    # highlights the option before or after the current highlight option
    # focus-adjacent-option :: Number -> Void
    focus-adjacent-option: (direction) !->
        @set-state do
            focused-option: clamp (@state.focused-option + direction), 0, @props.options.length - 1
            open: true    

    # is-below-limit :: Props -> Boolean
    is-below-limit: (props) -> 
        {max-values, values}? = props or @props
        (typeof max-values == \undefined) or values.length < max-values

    # removes all the selected values
    # reset : a -> Void
    reset: !-> @props.on-values-change []

    # select-option :: Number -> Void
    select-option: (index) !-> 
        @props.on-values-change @props.values ++ [@props.options?[index]]
        @props.on-search-change ""