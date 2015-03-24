{filter, find, map} = require \prelude-ls
{partition-string} = require \./prelude-extension
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class {

    display-name: 'SimpleOption'

    statics: {

        filter: (list, search) ->            
            filtered-list = list
                |> filter ({label}?) -> !!label                
                |> map ({label, value}) -> {label, value, partitions: (partition-string label.to-lower-case!, search.to-lower-case!)}
                |> filter ({partitions}) -> partitions.length > 0
            
            new-option = 
                | search.length > 0 and typeof (list |> find (.value == search)) == \undefined => [{label: search, value: search, new-option: true}]
                | _ => []

            new-option ++ filtered-list

    }

    render: ->
        {on-click, on-mouse-over, on-mouse-out, focused, index, label, value, new-option, partitions} = @.props
        div do 
            {
                class-name: "simple-option #{if focused then \focused else ''}"
                on-click
                on-mouse-over
                on-mouse-out
            }
            if index == 0 and !!new-option
                span null, "Add #{label}..."
            else
                partitions
                    |> map ([start, end, highlight]) -> span (if highlight then {class-name: \highlight} else null), (label.substring start, end)


}
