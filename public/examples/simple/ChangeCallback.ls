Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        div null,
            
            React.create-element SimpleSelect,
                ref: \select
                placeholder: "Select a country"
                options: @state.countries
                value: @state.country
                
                # on-value-change :: Item -> (a -> Void) -> void
                on-value-change: (country, callback) ~> @set-state {country}, callback
                
                # render-no-results-found :: a -> ReactElement
                render-no-results-found: ~>
                    div class-name: \no-results-found,
                        if !!@req then "loading countries ..." else "No results found"
            
            if !!@state.country
                div do 
                    style: margin: 8
                    span null, "you selected: "
                    span do 
                        style:
                            font-weight: \bold
                        @state.country.label

    # get-initial-state :: a -> UIState
    get-initial-state: ->
        countries: []
        country: undefined

    # component-will-mount :: a -> Void
    component-will-mount: ->
        @req = $.getJSON "https://restcountries.eu/rest/v1/all"
            ..done (countries) ~> 
                <~ @set-state do 
                    countries: countries |> map ({name, alpha2-code}) -> 
                        label: name, value: alpha2-code
                @refs.select.highlight-first-selectable-option!
            ..always ~> delete @req

React.render (React.create-element Form, null), mount-node