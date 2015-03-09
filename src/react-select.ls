{filter, find, last, map, partition, reverse, sort-by} = require \prelude-ls
{clamp, find-all, partition-string, remove} = require \./prelude-extension.ls
on-click-outside = require \react-onclickoutside
React = require \react
{div, input, span} = React.DOM
SimpleOption = require \./simple-option.ls
SimpleValue = require \./simple-value.ls

module.exports = React.create-class {

    display-name: \ReactSelect

    mixins: [on-click-outside]

    render: ->
        {            
            handle-click, handle-input-key-down, handle-option-click
            handle-option-mouse-over, handle-option-mouse-out, handle-remove-click
            handle-reset-click, handle-search-change, is-below-limit
            props: {options, placeholder-text, values, max-items, disabled, style, option-class, value-class}
            state: {focused-option, open, search}
        } = self = @        

        children = [            
            div do 
                {class-name: \control, key: \control}
                if (values.length == 0 and search.length == 0) then (div {class-name: \placeholder}, placeholder-text) else null
                values |> map (value) ->
                    React.create-element do 
                        (value-class or SimpleValue)
                        {key: value, on-remove-click: (handle-remove-click.bind self, value)} <<< (options |> find (.value == value)) or {}
                input {                    
                    disabled
                    ref: \search
                    type: \text
                    value: search                    
                    on-key-down: handle-input-key-down
                    style:
                        width: Math.max 16, (search.length * 16)
                } <<< (if @.is-below-limit! then {on-change: handle-search-change} else {})
                div {class-name: \reset, on-click: handle-reset-click}, \×
                div {class-name: \arrow}, null
        ]

        if open            
            children.push div do 
                {class-name: \options, key: \options}
                (@.filter-options search)
                    |> map ({index, value}:option-object) ->
                        React.create-element (option-class or SimpleOption), {} <<< option-object <<< {
                            key: "#{value}"                
                            ref: "option-#{index}"
                            focused: index == focused-option
                            on-click: (handle-option-click.bind self, index)
                            on-mouse-over: (handle-option-mouse-over.bind self, index)
                            on-mouse-out: handle-option-mouse-out
                        }
                
        div {class-name: "multi-select #{if disabled then 'disabled' else ''}  #{if open then 'open' else ''}", on-click: handle-click, style}, children
            
    select-option: (index) !->
        filtered-options = @.filter-options @.state.search
        {new-option, value}:option? = filtered-options?[index]
        @.props?.on-options-change ([option] ++ @.props.options) if !!new-option    
        @.props?.on-change (@.props.values ++ value) if !!value

    remove-value: (value) ->
        {new-option}:option? = @.props.options |> find -> it.value == value 
        @.props?.on-options-change (@.props.options |> remove -> it.value == value) if !!new-option
        @.props?.on-change (@.props.values |> remove (== value))
        option

    reset: ->
        @.props?.on-change []

    clear-and-foucs: ->
        @.set-state {search: ''}
        @.focus!

    component-did-update: ->
        return if @.state.focused-option == -1

        {parent-element}:option-element? = @?.refs?["option-#{@.state.focused-option}"]?.getDOMNode!
        return if !option-element

        option-height = option-element.offset-height - 1

        if (option-element.offset-top - parent-element.scroll-top) > parent-element.offset-height
            parent-element.scroll-top = option-element.offset-top - parent-element.offset-height + option-height

        else if (option-element.offset-top - parent-element.scroll-top + option-height) < 0
            parent-element.scroll-top = option-element.offset-top   

    component-will-receive-props: (new-props) ->
        @.set-state @.show-options @.state.open, new-props

    filter-options: (search) ->
        {option-class, options, values} = @.props
        result = (option-class or SimpleOption).filter (options |> filter ({value}) -> value not in values), search
        [0 til result.length]
            |> map (index) -> result[index] <<< {index}

    focus: ->
        @.refs.search.getDOMNode!.focus!

    focus-adjacent-option: (direction) ->
        {values} = @.props
        @.set-state {
            focused-option: clamp do 
                @.state.focused-option + direction
                0
                (@.filter-options @.state.search).length - 1            
        } <<< (@.show-options true)

    get-initial-state: ->
        {focused-option: 0, open: false, search: ''}

    handle-click: ->
        @.set-state @.show-options true
        @.focus!

    handle-click-outside: ->
        @.set-state {open: false}

    handle-input-key-down: ({which, prevent-default}) ->
        match which
            | 8 => 
                return if @.state.search.length > 0                
                {label} = @.remove-value last @.props.values
                if !!@.props?.restore-on-backspace
                    @.set-state {search: label, focused-option: 0} <<< (@.show-options true)
                else
                    @.set-state {open: false}
            | 13 => 
                @.select-option @.state.focused-option
                @.set-state {focused-option: -1, open: false, search: ''}
            | 27 =>
                if @.state.open
                    @.set-state {open: false}
                else
                    @.reset!
                @.clear-and-foucs!
            | 38 => @.focus-adjacent-option -1
            | 40 => @.focus-adjacent-option 1
            | _ => return
        false

    handle-option-click: (index) ->
        @.select-option index
        @.clear-and-foucs!
        false

    handle-option-mouse-over: (index) ->
        @.set-state {focused-option: index}

    handle-option-mouse-out: ->
        @.set-state {focused-option: -1}

    handle-remove-click: (value) ->
        @.remove-value value
        @.clear-and-foucs!
        false

    handle-reset-click: ->  
        @.reset!
        @.clear-and-foucs!
        false

    handle-search-change: ({current-target:{value}}) ->
        filtered-options = @.filter-options value
        @.set-state {
            focused-option: if filtered-options.length == 1 or typeof filtered-options?.0?.new-option == \undefined then 0 else 1
            open: (@.state.open or (value.length > 0))
            search: value
        }

    is-below-limit: (props) -> 
        {max-items, values}? = props or @.props
        typeof max-items == \undefined or values.length < max-items

    show-options: (show, props) ->
        {disabled, options, values} = props or @.props
        {open: show and (@.is-below-limit props) and !disabled and values.length < options.length}

}