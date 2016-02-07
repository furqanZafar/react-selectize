# {SimpleSelect} = require \react-selectize

Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select a fruit"
            theme: \material # can be one of \default | \bootstrap3 | \material | ...
            transition-enter: true

render (React.create-element Form, null), mount-node