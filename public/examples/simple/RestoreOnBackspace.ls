create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select a fruit"
            
            # restore-on-backspace :: Item -> String
            restore-on-backspace: ~> it.label.substr 0, it.label.length - 1
                
render (React.create-element Form, null), mount-node