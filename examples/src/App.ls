ReactSelect = require \../../src/react-select.ls
React = require \react

App = React.create-class {

    render: -> 
        React.create-element ReactSelect, {
            values: @.state.selected-countries
            options: @.props.countries
            on-change: @.handle-countries-change
        }        

    get-initial-state: ->
        {selected-countries: []}

    handle-countries-change: (selected-countries) ->
        @.set-state {selected-countries}

}

countries = [{value: \ae, label: \UAE}, {value: \pk, label: \Pakistan}, {value: \us, label: \USA}]

React.render (React.create-element App, {countries}), document.body