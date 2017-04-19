create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        div null,
            
            React.create-element SimpleSelect,
                ref: \select
                placeholder: "Select a country"
                options: @state.countries
                value: @state.country
                
                # on-value-change :: Item -> (a -> Void) -> void
                on-value-change: (country) ~> @set-state {country}
                
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
        @req = $.getJSON "http://restverse.com/countries"
            ..done (countries) ~> 
                <~ @set-state {countries}
                @refs.select.highlight-first-selectable-option!
            ..always ~> delete @req

render (React.create-element Form, null), mount-node