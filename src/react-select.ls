find-all = (text, search, offset = 0, indices = []) ->
    index = text .substr offset .index-of search
    return indices if index == -1
    find-all do
        text
        search
        offset + index + search.length
        indices ++ [offset + index]

partition-string = (text, search) ->
    return [[0, text.length]] if search.length == 0
    [first, ..., x]:indices = find-all text, search
    return [] if indices.length == 0
    last = x + search.length
    high = indices
        |> map -> [it, it + search.length, true]
    low = [0 til high.length - 1]
        |> map (i) ->
            [high[i].1, high[i + 1].0, false]
    (if first == 0 then [] else [[0, first, false]]) ++
    ((high ++ low) |> sort-by (.0)) ++
    (if last == text.length then [] else [[last, text.length, false]])

{filter, find, map, partition, reverse, sort-by} = require \prelude-ls
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
            handle-reset-click, handle-search-change
            props: {options, placeholder-text, values, max-items}
            state: {filtered-options, focused-option, open, search}
        } = self = @

        is-below-limit = typeof @.props.max-items == \undefined or @.props.values.length < @.props.max-items

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
                    ref: \search
                    type: \text
                    value: search                    
                    on-key-down: handle-input-key-down
                    style:
                        width: Math.max 16, (search.length * 16)
                } <<< (if is-below-limit then {on-change: handle-search-change} else {})
                div {class-name: \reset, on-click: handle-reset-click}, \×
                div {class-name: \arrow}, null
        ]

        if open and is-below-limit
            filtered-options = @.filter-options search
            children.push div do 
                {class-name: \options, key: \options}
                [0 til filtered-options.length]
                    |> map -> {index: it} <<< filtered-options[it]
                    |> map ({index, value, label or '', partitions}?) ->
                        div do 
                            {
                                class-name: (if index == focused-option then \focused else '')
                                key: "#{value}"
                                on-click: (handle-option-click.bind self, value)
                                on-mouse-over: (handle-option-mouse-over.bind self, index)
                                on-mouse-out: handle-option-mouse-out
                                ref: "option-#{index}"
                            }
                            partitions
                                |> map ([start, end, highlight]) -> span (if highlight then {class-name: \highlight} else null), (label.substring start, end)
                
        div {class-name: "multi-select  #{if open then 'open' else ''}", on-click: handle-click}, children
            
    clamp: (n, min, max) -> Math.max min, (Math.min max, n)

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

    filter-options: (search) ->
        {options, values} = @.props        
        filtered-options = options                    
            |> filter ({label}?) -> !!label
            |> filter ({value}) -> value not in values
            |> map ({label, value}) -> {label, value, partitions: (partition-string label.to-lower-case!, search.to-lower-case!)}
            |> filter ({partitions}) -> partitions.length > 0        
        new-option = 
            | search.length > 0 and typeof (options |> find (.value == search)) == \undefined =>
                label = "Add #{search}..."
                [{value: search, label, partitions: [[0, label.length]], new-option: true}]
            | _ => []
        new-option ++ filtered-options

    focus: ->
        @.refs.search.getDOMNode!.focus!

    focus-adjacent-option: (direction) ->
        {values} = @.props        
        @.set-state {
            focused-option: @.clamp do 
                @.state.focused-option + direction
                0
                (@.filter-options @.state.search).length - 1
            open: true
        }

    get-initial-state: ->
        search = ''
        {
            filtered-options: @.filter-options @.props.options, search
            focused-option: 0
            open: false
            search
        }

    handle-click: ->
        @.set-state {open: true}
        @.focus!

    handle-click-outside: ->
        @.set-state {open: false}

    handle-input-key-down: ({which, prevent-default}) ->
        match which
            | 8 => 
                return if @.state.search.length > 0
                [...xs, x] = @.props.values
                @.props?.on-change xs
                if !!@.props?.restore-on-backspace
                    @.set-state {open: true, search: (@.props.options |> find ({value}) -> x == value).label, focused-option: 0}
                else
                    @.set-state {open: false}
            | 13 => 
                filtered-options = @.filter-options @.state.search
                {new-option, label, value}:option? = filtered-options?[@.state.focused-option]
                @.props?.on-change (@.props.values ++ value)
                @.props?.on-options-change ([{label: value, value}] ++ @.props.options) if !!new-option
                @.set-state {focused-option: -1, open: false, search: ''}
            | 27 =>
                if @.state.open 
                    @.set-state {open: false}
                else
                    @.props?.on-change []
                @.clear-and-foucs!
            | 38 => @.focus-adjacent-option -1
            | 40 => @.focus-adjacent-option 1
            | _ => return
        false

    handle-option-click: (value) ->
        @.props?.on-change (@.props.values ++ value)        
        @.clear-and-foucs!
        false

    handle-option-mouse-over: (index) ->
        @.set-state {focused-option: index}

    handle-option-mouse-out: ->
        @.set-state {focused-option: -1}

    handle-remove-click: (value) ->
        @.props?.on-change (@.props.values |> partition (== value) |> (.1))
        @.clear-and-foucs!
        false

    handle-reset-click: ->  
        @.props?.on-change []
        @.clear-and-foucs!
        false

    handle-search-change: ({current-target:{value}}) ->
        filtered-options = @.filter-options value
        @.set-state {
            focused-option: if filtered-options.length == 1 or typeof filtered-options?.0?.new-option == \undefined then 0 else 1
            open: (@.state.open or (value.length > 0))
            search: value
        }
        

}