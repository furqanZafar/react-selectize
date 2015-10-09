Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        div null,
        
            # MAKES
            React.create-element SimpleSelect,
                placeholder: "Select a make"
                options: @state.makes |> map ~> label: it, value: it
                value: @state.make
                
                # on-value-change :: Item -> (a -> Void) -> Void
                on-value-change: (make, callback) !~> 
                    <~ @set-state {make, model: undefined}
                    @refs.models.focus callback
                
                # on-focus :: Item -> String -> Void
                on-focus: (item, reason) ~>
                    @set-state focused: true
                
                # on-blur :: Item -> String -> Void
                on-blur: (item, reason) !~>
                    @set-state focused:false
                    
                style: if @state.focused then color: "#0099ff" else {}
                    
            # MODELS
            React.create-element SimpleSelect,
                ref: \models
                placeholder: "Select a model"
                options: (@state.models?[@state?.make?.label] ? []) |> map ~> label: it, value: it
                value: @state.model
                
                # disabled :: Boolean
                disabled: typeof @state.make == \undefined
                
                on-value-change: (model, callback) ~> @set-state {model}, callback
                style: margin-top: 20, opacity: if !!@state.make then 1 else 0.5
                    
    # get-initial-state :: a -> UIState
    get-initial-state: -> 
        focused: false
        make: undefined
        makes: ["Bentley", "Cadillac", "Lamborghini", "Maserati", "Volkswagen"]
        model: undefined
        models: 
            Bentley: ["Arnage", "Azure", "Continental", "Corniche", "Turbo R"]
            Cadillac: ["Allante", "Catera", "Eldorado", "Fleetwood", "Seville"]
            Lamborghini: ["Aventador", "Countach", "Diablo", "Gallardo", "Murcielago"]
            Maserati: ["Bitturbo", "Coupe", "GranTurismo", "Quattroporte", "Spyder"]
            Volkswagen: ["Beetle", "Fox", "Jetta", "Passat", "Rabbit"]
              
    
render (React.create-element Form, null), mount-node