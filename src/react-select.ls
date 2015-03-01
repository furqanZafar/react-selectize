{filter, find, map, partition, reverse} = require \prelude-ls
on-click-outside = require \react-onclickoutside
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class {

    display-name: \ReactSelect

    mixins: [on-click-outside]

    render: ->
        {
            handle-click
            handle-input-key-down
            handle-option-click
            handle-option-mouse-over
            handle-option-mouse-out
            handle-remove-click
            handle-reset-click
            handle-search-change
            props: {options, placeholder-text, values}
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
                    ref: \search
                    type: \text
                    value: search
                    on-change: handle-search-change
                    on-key-down: handle-input-key-down
                    style:
                        width: Math.max 16, (search.length * 16)
                }
                div {class-name: \reset, on-click: handle-reset-click}, \×
                div {class-name: \arrow}, null
        ]

        filtered-options = @.filter-options!

        if open
            children.push div do 
                {class-name: \options, key: \options}
                [0 til filtered-options.length]
                    |> map -> {index: it} <<< filtered-options[it]
                    |> map ({index, value, label or ''}?) ->
                        div do 
                            {
                                class-name: (if index == focused-option then \focused else '')
                                key: value
                                on-click: (handle-option-click.bind self, value)
                                on-mouse-over: (handle-option-mouse-over.bind self, index)
                                on-mouse-out: handle-option-mouse-out
                                ref: "option-#{index}"
                            }
                            label
                
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


    filter-options: ->
        {search} = @.state
        {options, values} = @.props
        options
            |> filter ({label or ''}?) -> (label.to-lower-case!.index-of search.to-lower-case!) > -1
            |> filter ({value}) -> value not in values

    focus: ->
        @.refs.search.getDOMNode!.focus!

    focus-adjacent-option: (direction) ->
        {values} = @.props
        @.set-state {
            focused-option: @.clamp (@.state.focused-option + direction), 0, (@.filter-options!.length - 1)
            open: true
        }

    get-initial-state: ->
        {focused-option: 0, open: false, search: ''}        

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
                @.set-state {open: false}
            | 13 => 
                focused-value = @.filter-options!?[@.state.focused-option]?.value
                if !!focused-value
                    @.props?.on-change (@.props.values ++ focused-value)
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
        @.set-state {focused-option: 0, open: (@.state.open or (value.length > 0)), search: value}


}