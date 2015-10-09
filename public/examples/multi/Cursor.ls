Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect,
            placeholder: "Select youtube channels"

            # set anchor to undefined, to lock the cursor at the start
            # anchor :: Item
            anchor: @state.anchor 

            options: @state.channels
            values: @state.selected-channels
            on-values-change: (selected-channels, callback) !~> 
                # lock the cursor at the end
                @set-state {anchor: (last selected-channels), selected-channels}, callback

    # get-initial-state :: a -> UIState
    get-initial-state: ->
        channels = ["Dude perfect", "In a nutshell", "Smarter everyday", "Vsauce", "Veratasium"]
            |> map ~> label: it, value: it
        anchor: last channels
        channels: channels
        selected-channels: [last channels]
                
render (React.create-element Form, null), mount-node