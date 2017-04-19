# {MultiSelect} = require \react-selectize

create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select fruits"

render (React.create-element Form, null), mount-node