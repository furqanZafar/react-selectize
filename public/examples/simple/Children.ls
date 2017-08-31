SimpleSelectFactory = React.create-factory SimpleSelect

create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        React.DOM.form do
            action: \/

            SimpleSelectFactory do
                placeholder: "Select a fruit"
                ref: \select

                # default value support
                default-value: label: \apple, value: \apple

                # on change callback
                on-value-change: (selected-fruit) ~> 
                    console.log "selected value: #{JSON.stringify selected-fruit, null, 4}"

                # form serialization
                name: \fruit
                serialize: (?.value) # <- optional in this case, default implementation

                # options from children
                <[apple mango grapes melon strawberry]> |> map ~>
                    option key: it, value: it, it

            # clicking submit would make a GET request to the current page
            # with fruit={{selected value}} in the query string
            input do 
                type: \submit
                style: 
                    cursor: \pointer
                    height: 24
                    margin-top: 10
                on-click: ~> 
                    alert "selected value: #{JSON.stringify @refs.select.value!, null, 4}"

render (React.create-element Form, null), mount-node