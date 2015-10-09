Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select 2 fruits"
            max-values: 2
                
render (React.create-element Form, null), mount-node