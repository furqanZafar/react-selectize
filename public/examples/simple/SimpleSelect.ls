# {SimpleSelect} = require \react-selectize

create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select a fruit"
            ddm: "dropdown-menu"

render (React.create-element Form, null), mount-node