$ = require \jquery-browserify
{concat-map, filter, map, unique-by} = require \prelude-ls
{create-factory, DOM:{a, div, h1, h2}}:React = require \react
require! \./EmailOption.ls
require! \./EmailValue.ls
ReactSelectize = create-factory require \../../src/ReactSelectize.ls

App = React.create-class do

    render: -> 
        div null,
            div {class-name: \title}, 'React Auto Complete'
            div {class-name: \description}, 'A flexible and beautiful Select input control for ReactJS with multiselect & autocomplete'
            a {class-name: \github-link, href: 'http://github.com/furqanZafar/react-select/tree/develop', target: \_blank}, 'View project on GitHub'
            h1 null, 'Examples:'

            # COUNTRIES
            ReactSelectize do 
                add-options: true
                max-items: 2
                values: @state.selected-countries
                options: @state.countries
                on-change: (selected-countries) ~>
                    @set-state {selected-countries}
                    cities = selected-countries |> concat-map (country) ~> 
                        [1 to 3] |> map (index) ~> 
                            {label: "#{country}_#{index}", value: "#{country}_#{index}"}
                    selected-cities = @state.selected-cities |> filter (city) ~> city in (cities |> map (.value))
                    @set-state {cities, selected-cities}
                on-options-change: (options) ~> @set-state {countries: options}
                placeholder: 'Select countries'
                style: z-index: 1

            # CITIES
            ReactSelectize do
                disabled: @state.selected-countries.length == 0
                values: @state.selected-cities
                options: @state.cities
                on-change: (selected-cities) ~> @set-state {selected-cities}
                placeholder: 'Select cities'
                # max-items: 2
                style: margin-top: 20, z-index: 0
                
            div {class-name: \copy-right}, 'Copyright © Furqan Zafar 2014. MIT Licensed.'

    get-initial-state: ->
        countries: [], selected-countries: [], cities: [], selected-cities: []

    component-will-mount: ->
        $.getJSON 'http://restcountries.eu/rest/v1/all'
            ..done (countries) ~> @set-state countries: unique-by (.value), (@state.countries ? []) ++ (countries |> map -> value: it.alpha2Code, label: it.name)
            ..fail ~> console.log 'unable to fetch countries'

React.render do
    React.create-element do 
        App
        countries: [{value: \ae, label: \UAE}, {value: \us, label: \USA}]
    document.body