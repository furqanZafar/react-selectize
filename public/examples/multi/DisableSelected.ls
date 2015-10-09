Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select fruits"

            # filter-options :: [Item] -> [Item] -> String -> [Item]
            filter-options: (options, values, search) ~>
                options 
                    |> filter -> (it.label.index-of search) > -1
                    |> map -> {} <<< it <<< selectable: !(it.value in (map (.value), values))

render (React.create-element Form, null), mount-node