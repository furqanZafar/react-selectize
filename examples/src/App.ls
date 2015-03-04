ReactSelect = require \../../src/react-select.ls
React = require \react
{a, div, h1, h2} = React.DOM
$ = require \jquery-browserify
{map} = require \prelude-ls

App = React.create-class {

    render: -> 
        div null,
            div {class-name: \title}, 'React Select'
            div {class-name: \description}, 'A flexible and beautiful Select input control for ReactJS with multiselect & autocomplete'
            a {class-name: \github-link, href: 'http://github.com/furqanZafar/react-select/tree/develop', target: \_blank}, 'View project on GitHub'
            h1 null, 'Examples:'
            h2 null, 'MULTISELECT:'
            React.create-element ReactSelect, {
                values: @.state.selected-countries
                options: @.state.countries
                on-change: @.handle-countries-change
                placeholder-text: 'Select countries'
                restore-on-backspace: false
                max-items: 3
            }
            div {class-name: \copy-right}, 'Copyright © Furqan Zafar 2014. MIT Licensed.'

    get-initial-state: ->        
        {selected-countries: [], countries: []}

    component-will-mount: ->
        self = @
        $.getJSON 'http://restcountries.eu/rest/v1/all'
            ..done (countries) -> self.set-state do 
                countries: countries |> map ({name, alpha2Code}) -> {value: alpha2Code, label: name}
            ..fail -> console.log 'unable to fetch countries'

    handle-countries-change: (selected-countries) ->
        @.set-state {selected-countries}

}

countries = [{value: \ae, label: \UAE}, {value: \us, label: \USA}]

React.render (React.create-element App, {countries}), document.body