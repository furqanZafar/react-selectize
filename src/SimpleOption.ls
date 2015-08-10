{filter, find, map} = require \prelude-ls
{partition-string} = require \prelude-extension
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class do

    display-name: \SimpleOption

    statics:

        # [SimpleOption] -> String -> Options -> [SimpleOption]
        filter: (list, search, {add-options}) ->

            # filter the list of options by with search string
            filtered-list = list
                |> filter -> !!it.label
                |> map ({label, value}) -> {label, value, partitions: (partition-string label.to-lower-case!, search?.to-lower-case!)}
                |> filter (.partitions.length > 0)
            
            # if add-options is true and the search returned no result then create and return a list with a single new option
            if add-options
                new-option = 
                    | search.length > 0 and filtered-list.length == 0 => [{label: search, value: search, new-option: true}]
                    | _ => []
                new-option ++ filtered-list

            else 
                filtered-list


    render: ->

        {focused, index, label, value, add-options, new-option, partitions} = @props

        # SimpleOption
        div do 
            class-name: "simple-option #{if focused then \focused else ''}"
            if add-options and (index == 0 and !!new-option)
                span null, "Add #{label}..."
            else
                partitions |> map ([start, end, highlight]) ~> 
                    span do
                        class-name: if highlight then \highlight else ''
                        key: "#{start}-#{end}"
                        label.substring start, end


