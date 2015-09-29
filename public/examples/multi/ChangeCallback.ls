Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        div null,
            
            # SELECTED COUNTRIES
            if @state.selected-countries.length > 0
                div do 
                    style: margin: 8
                    span null, "you selected: "
                    span do 
                        style:
                            font-weight: \bold
                        @state.selected-countries
                            |> map (.label)
                            |> Str.join ', '

            # MULTISELECT
            React.create-element MultiSelect,
                ref: \select
                placeholder: "Select countries"
                options: @state.countries
                value: @state.selected-countries

                # on-value-change :: Item -> (a -> Void) -> void
                on-values-change: (selected-countries, callback) ~> @set-state {selected-countries}, callback
                
                # render-no-results-found :: a -> ReactElement
                render-no-results-found: ~>
                    div class-name: \no-results-found,
                        if !!@req then "loading countries ..." else "No results found"
            

    # get-initial-state :: a -> UIState
    get-initial-state: ->
        countries: []
        selected-countries: []

    # component-will-mount :: a -> Void
    component-will-mount: ->
        @req = $.getJSON "http://restverse.com/countries"
            ..done (countries) ~> 
                <~ @set-state {countries}
                @refs.select.highlight-first-selectable-option!
            ..always ~> delete @req

React.render (React.create-element Form, null), mount-node