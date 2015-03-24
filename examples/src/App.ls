ReactSelectize = require \../../src/react-selectize.ls
React = require \react
{a, div, h1, h2} = React.DOM
$ = require \jquery-browserify
{concat-map, filter, map} = require \prelude-ls
EmailOption = require \./EmailOption.ls
EmailValue = require \./EmailValue.ls

App = React.create-class {

    render: -> 
        div null,
            div {class-name: \title}, 'React Select'
            div {class-name: \description}, 'A flexible and beautiful Select input control for ReactJS with multiselect & autocomplete'
            a {class-name: \github-link, href: 'http://github.com/furqanZafar/react-select/tree/develop', target: \_blank}, 'View project on GitHub'
            h1 null, 'Examples:'
            h2 null, 'MULTISELECT:'            
            React.create-element ReactSelectize, {
                values: @.state.selected-countries
                options: @.state.countries
                on-change: @.handle-countries-change
                on-options-change: @.handle-options-change
                placeholder-text: 'Select countries'
                max-items: 2
                style: {z-index: 1}
            }
            React.create-element ReactSelectize, {
                disabled: @.state.selected-countries.length == 0
                values: @.state.selected-cities
                options: @.state.cities
                on-change: @.handle-cities-change
                placeholder-text: 'Select cities'
                max-items: 2
                style: {margin-top: 20, z-index: 0}
            }
            # React.create-element ReactSelectize, {
            #     values: @.state.selected-users
            #     options: @.state.users
            #     on-change: @.handle-users-change                
            #     placeholder-text: 'Select users'
            #     option-class: EmailOption
            #     value-class: EmailValue
            #     multi: true
            # }
            div {class-name: \copy-right}, 'Copyright © Furqan Zafar 2014. MIT Licensed.'

    get-initial-state: ->        
        users = [
            {
                first-name: \john
                last-name: \d
                value: \john.d@a.com
            }
            {
                first-name: \jack
                last-name: \s
                value: \jack.s@b.com
            }
        ]
        {selected-countries: [], countries: [], selected-cities: [], cities: [], selected-users: [], users}

    component-will-mount: ->
        self = @
        $.getJSON 'http://restcountries.eu/rest/v1/all'
            ..done (countries) -> self.set-state do 
                countries: (self.state.countries or []) ++ (countries |> map ({name, alpha2Code}) -> {value: alpha2Code, label: name})
            ..fail -> console.log 'unable to fetch countries'

    handle-countries-change: (selected-countries) ->
        @.set-state {selected-countries}

        cities = selected-countries |> concat-map (country) -> 
            [1 to 3] |> map (index) -> 
                {label: "#{country}_#{index}", value: "#{country}_#{index}"}

        selected-cities = @.state.selected-cities
            |> filter (city) -> city in (cities |> map (.value))

        @.set-state {cities, selected-cities}

    handle-cities-change: (selected-cities) ->
        @.set-state {selected-cities}

    handle-users-change: (selected-users) ->
        @.set-state {selected-users}

    handle-options-change: (options) ->
        @.set-state {countries: options}

}

countries = [{value: \ae, label: \UAE}, {value: \us, label: \USA}]

React.render (React.create-element App, {countries}), document.body