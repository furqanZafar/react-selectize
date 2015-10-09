SimpleSelectFactory = React.create-factory SimpleSelect

Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        div null,

            SimpleSelectFactory do
                placeholder: "Select a fruit"
                ref: \select
                on-value-change: (selected-fruit, callback) ~> 
                    alert "selected value: #{JSON.stringify selected-fruit, null, 4}"
                    callback!
                <[apple mango grapes melon strawberry]> |> map ~>
                    option key: it, value: it, it

            button do 
                style: 
                    cursor: \pointer
                    height: 24
                    margin-top: 10
                on-click: ~> 
                    alert "selected value: #{JSON.stringify @refs.select.value!, null, 4}"
                "Get current value"

render (React.create-element Form, null), mount-node