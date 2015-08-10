{filter, find, last, map, partition, reject, reverse, sort-by} = require \prelude-ls
{clamp, find-all, partition-string} = require \prelude-extension
on-click-outside = require \react-onclickoutside
{DOM:{div, input, span}}:React = require \react
require! \./SimpleOption
require! \./SimpleValue

module.exports = React.create-class do

    display-name: \ReactSelectize

    mixins: [on-click-outside]

    # get-default-props :: a -> Props
    get-default-props: ->
        add-options: false
        disabled: false
        max-items: 1
        on-blur: ((values) ->)
        on-change: ((values) ->)
        on-options-change: ((options) ->)
        option-class: SimpleOption
        options: [] # options :: [Option]
        restore-on-backspace: false
        style: {}
        value-class: SimpleValue
        values: [] # values :: [String]

    # render :: a -> ReactElement
    render: ->
        
        show-options = switch
            | @props.disabled => false
            | !@is-below-limit! => false
            | @props.values.length > 0 and @props.values.length == @props.options.length => false
            | _ => @state.open

        # MULTISELECT
        div do 
            class-name: "multi-select #{if @props.disabled then 'disabled' else ''} #{if show-options then 'open' else ''}"
            style: @props.style
            on-click: ~>
                @set-state open: true
                @focus!

            # CONTROL
            div do 
                class-name: \control
                key: \control

                # PLACEHOLDER TEXT
                if @state.search.length == 0 and @props.values.length == 0
                    div do 
                        class-name: \placeholder
                        @props.placeholder

                # LIST OF SELECTED VALUES
                @props.values |> map (value) ~>
                    React.create-element do 
                        @props.value-class
                        {
                            key: value
                            on-remove-click: (e) ~> 
                                @remove-value value
                                @clear-and-foucs!
                                e.prevent-default!
                                e.stop-propagation!
                        } <<< (@props.options |> find (.value == value)) or {}

                # SEARCH INPUT BOX
                input {
                    disabled: @props.disabled
                    ref: \search
                    type: \text
                    value: @state.search
                    on-key-down: (e) ~>
                        if e.which == 9
                            <~ @set-state open: false
                            @props.on-blur @props.values
                        else
                            match e.which

                                # BACKSPACE
                                | 8 => 
                                    return if @state.search.length > 0

                                    {label}? = @remove-value last @props.values
                                    if !!label and !!@props.restore-on-backspace
                                        @set-state do 
                                            focused-option: 0
                                            open: true
                                            search: label
                                    else
                                        @set-state open: false

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

                                | _ => return
                            e.prevent-default!
                            e.stop-propagation!

                    style: width: Math.max 16, (@state.search.length * 16)

                } <<< (
                    if @is-below-limit!
                        on-change: ({current-target:{value}}) ~>
                            filtered-options = @filter-options value
                            @set-state do
                                focused-option: if filtered-options.length == 1 or typeof filtered-options?.0?.new-option == \undefined then 0 else 1
                                open: @state.open or filtered-options.length > 0
                                search: value
                    else
                        {}
                )

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
                div do 
                    class-name: \options
                    (@filter-options @state.search) |> map ({index, value}:option-object) ~>
                        div do
                            ref: "option-#{index}"
                            key: "#{value}"
                            on-click: (e) ~>
                                @set-state {open: false}, ~>
                                    @select-option index
                                    @clear-and-foucs!
                                e.prevent-default!
                                e.stop-propagation!
                            on-mouse-over: ~> @set-state focused-option: index
                            on-mouse-out: ~> @set-state focused-option: -1
                            React.create-element do 
                                @props.option-class
                                {} <<< option-object <<<
                                    add-options: @props.add-options
                                    focused: index == @state.focused-option

    # get-initial-state :: a -> UIState
    get-initial-state: -> focused-option: 0, open: false, search: ''

    # component-did-update :: a -> Void
    component-did-update: !->
        return if @state.focused-option == -1

        {parent-element}:option-element? = @?.refs?["option-#{@state.focused-option}"]?.getDOMNode!
        return if !option-element

        option-height = option-element.offset-height - 1

        if (option-element.offset-top - parent-element.scroll-top) > parent-element.offset-height
            parent-element.scroll-top = option-element.offset-top - parent-element.offset-height + option-height

        else if (option-element.offset-top - parent-element.scroll-top + option-height) < 0
            parent-element.scroll-top = option-element.offset-top   

    # clear-and-focus :: a -> Void    
    clear-and-foucs: !->
        @set-state search: ''
        @focus!

    # filter-options :: String -> [Option]
    filter-options: (search) ->
        {add-options, option-class, options, values} = @props
        result = option-class.filter (options |> filter ({value}) -> value not in values), search, {add-options}
        [0 til result.length] |> map (index) -> result[index] <<< {index}

    # focuses on the cursor search input
    # focus :: a -> Void
    focus: !-> @refs.search.getDOMNode!.focus!

    # highlights the option before or after the current highlight option
    # focus-adjacent-option :: Number -> Void
    focus-adjacent-option: (direction) !->
        @set-state do
            focused-option: clamp (@state.focused-option + direction), 0, (@filter-options @state.search).length - 1
            open: true

    # close the list of options when the user clicks outside (required by the on-click-outside mixin)
    # handle-click-outside :: a -> Void
    handle-click-outside: !-> @set-state open: false

    # is-below-limit :: Props -> Boolean
    is-below-limit: (props) -> 
        {max-items, values}? = props or @props
        typeof max-items == \undefined or values.length < max-items

    # returns the removed option corresponding to the given value
    # remove-value :: String -> Option
    remove-value: (value) ->
        {new-option}:option? = @props.options |> find -> it.value == value 
        @props.on-options-change (@props.options |> reject -> it.value == value) if !!new-option
        @props.on-change (@props.values |> reject (== value))
        option

    # reset : a -> Void
    reset: !-> @props.on-change []
        
    # select-option :: Number -> Void
    select-option: (index) !->
        filtered-options = @filter-options @state.search
        {new-option, value}:option? = filtered-options?[index]
        if !!new-option
            @props.on-options-change ([option] ++ @props.options) 
        if !!value
            @props.on-change @props.values ++ value