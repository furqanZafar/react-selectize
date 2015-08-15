$ = require \jquery-browserify
{concat-map, filter, find, map, reject, unique-by} = require \prelude-ls
{create-factory, DOM:{a, div, h1, h2, span}}:React = require \react
ReactSelectize = create-factory require \../../src/ReactSelectize.ls

App = React.create-class do

    render: -> 
        div null,
            div {class-name: \title}, 'React Selectize'
            div {class-name: \description}, 'A flexible and beautiful Multi Select input control for ReactJS'
            a {class-name: \github-link, href: 'http://github.com/furqanZafar/react-select/tree/develop', target: \_blank}, 'View project on GitHub'
            h1 null, 'Examples:'

            # COUNTRIES
            ReactSelectize do 
                options: @state.countries 
                    |> reject ~> it.label.to-lower-case!.trim! in (map (.label.to-lower-case!.trim!), @state.selected-countries)
                    |> filter ~> (it.label.to-lower-case!.trim!.index-of @state.countries-search.to-lower-case!.trim!) > -1                    
                    |> (options) ~> 
                        {countries-search, selected-countries} = @state
                        return options if options.length > 0
                        return [] if countries-search.length == 0
                        return [] if !!(find (.label.to-lower-case!.trim! == countries-search.to-lower-case!.trim!), selected-countries)
                        [{label: countries-search, value: countries-search, new-option: true}]
                render-option: (index, focused, {label, new-option}?) ~>
                    div do 
                        class-name: "simple-option #{if focused then 'focused' else ''}"
                        key: index
                        if !!new-option then "Add #label ..." else label
                search: @state.countries-search
                on-search-change: (search) ~> @set-state countries-search:search
                values: @state.selected-countries
                max-values: 2
                on-values-change: (selected-countries) ~>
                    cities = selected-countries |> concat-map (country) ~> 
                        [1 to 3] |> map (index) ~> 
                            label: "#{country}_#{index}", value: "#{country}_#{index}"
                    selected-cities = @state.selected-cities |> filter (city) ~> city in (cities |> map (.value))
                    @set-state {selected-countries, cities, selected-cities}
                render-value: (index, {label}) ~>
                    div do 
                        class-name: \simple-value
                        key: index
                        span null, \x
                        span null, label
                placeholder: 'Select countries'
                restore-on-backspace: (.label)
                style: z-index: 1

            # CITIES
            # ReactSelectize do
            #     disabled: @state.selected-countries.length == 0
            #     values: @state.selected-cities
            #     options: @state.cities
            #     on-change: (selected-cities) ~> @set-state {selected-cities}
            #     placeholder: 'Select cities'
            #     # max-items: 2
            #     style: margin-top: 20, z-index: 0
                
            div {class-name: \copy-right}, 'Copyright © Furqan Zafar 2015. MIT Licensed.'

    get-initial-state: ->
        countries-search: "", countries: [], selected-countries: [], cities: [], selected-cities: []

    component-will-mount: ->
        $.getJSON 'http://restcountries.eu/rest/v1/all'
            ..done (countries) ~> @set-state countries: unique-by (.value), (@state.countries ? []) ++ (countries |> map -> value: it.alpha2Code, label: it.name)
            ..fail ~> console.log 'unable to fetch countries'

React.render do
    React.create-element do 
        App
        countries: [{value: \ae, label: \UAE}, {value: \us, label: \USA}]
    document.body