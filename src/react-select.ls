{filter, find, last, map, partition, reverse, sort-by} = require \prelude-ls
{clamp, find-all, partition-string, remove} = require \./prelude-extension.ls
on-click-outside = require \react-onclickoutside
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class {

    display-name: \ReactSelect

    mixins: [on-click-outside]

    render: ->
        {            
            handle-click, handle-input-key-down, handle-option-click
            handle-option-mouse-over, handle-option-mouse-out, handle-remove-click
            handle-reset-click, handle-search-change, is-below-limit
            props: {options, placeholder-text, values, max-items, disabled, style}
            state: {focused-option, open, search}
        } = self = @        

        children = [            
            div do 
                {class-name: \control, key: \control}
                if (values.length == 0 and search.length == 0) then (div {class-name: \placeholder}, placeholder-text) else null
                values
                    |> map (value) -> 
                        {label or ''}? = options |> find (.value == value)
                        div {class-name: \selected-value, key: value}, 
                            span {on-click: (handle-remove-click.bind self, value)}, \×
                            span null, label
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
            filtered-options = @.filter-options search
            children.push div do 
                {class-name: \options, key: \options}
                [0 til filtered-options.length]
                    |> map -> {index: it} <<< filtered-options[it]
                    |> map ({index, value, label or '', partitions, new-option}?) ->
                        div do 
                            {
                                class-name: (if index == focused-option then \focused else '')
                                key: "#{value}"
                                on-click: (handle-option-click.bind self, index)
                                on-mouse-over: (handle-option-mouse-over.bind self, index)
                                on-mouse-out: handle-option-mouse-out
                                ref: "option-#{index}"
                            }
                            if index == 0 and !!new-option
                                span null, "Add #{label}..."
                            else
                                partitions
                                    |> map ([start, end, highlight]) -> span (if highlight then {class-name: \highlight} else null), (label.substring start, end)
                
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
        {options, values} = @.props        
        filtered-options = options                    
            |> filter ({label}?) -> !!label
            |> filter ({value}) -> value not in values
            |> map ({label, value}) -> {label, value, partitions: (partition-string label.to-lower-case!, search.to-lower-case!)}
            |> filter ({partitions}) -> partitions.length > 0

        if !!@.props.create
            {label, value} = @.props.create search
            new-option = 
                | search.length > 0 and typeof (options |> find (.value == value)) == \undefined => [{label, value, partitions: [[0, label.length]], new-option: true}]
                | _ => []
            new-option ++ filtered-options

        else
            filtered-options

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
        {disabled} = props or @.props
        {open: show and (@.is-below-limit props) and !disabled}

}