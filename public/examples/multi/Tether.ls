# {MultiSelect} = require \react-selectize

create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        div do 
            style: border: '1px solid #000', height: 100, overflow: \auto, padding: 20

            # RANDOM TEXT
            div do 
                style: padding: 20
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit"

            # MULTISELECT
            React.create-element MultiSelect,
                tether: true
                options: <[apple mango grapes melon strawberry cherry banana kiwi]> |> map ~> label: it, value: it
                placeholder: "Select fruits"

            # RANDOM TEXT
            div do 
                style: padding: 20
                "Fusce aliquet dui tortor, imperdiet viverra augue pretium nec"


render (React.create-element Form, null), mount-node