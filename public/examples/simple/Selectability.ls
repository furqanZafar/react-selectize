Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            placeholder: "Select an iPhone model"
            options: @state.models
            
            # render-option :: Int -> Item -> ReactElement
            render-option: ({label, value, selectable}) ~>
                div do 
                    class-name: \simple-option
                    style: 
                        | selectable => {}
                        | _ =>
                            background-color: '#f8f8f8'
                            color: '#999'
                            cursor: \default
                            font-style: \oblique
                            text-shadow: "0px 1px 0px white"
                    span null, label
                    if !selectable
                        span do 
                            style:
                                color: '#c5695c'
                                float: \right
                                font-size: 12
                            "(out of stock)"
                    
    get-initial-state: ->
        models: [16, 64, 128] |> concat-map (size) ->
            ["Space Grey", "Silver", "Gold"] |> map (color) -> 
                label: "#{size}GB #{color}"
                value: "#{size}#{color}"
                selectable: Math.random! < 0.5
            
React.render (React.create-element Form, null), mount-node