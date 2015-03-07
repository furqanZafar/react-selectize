{filter, find, map} = require \prelude-ls
{partition-string} = require \./prelude-extension.ls
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class {

    display-name: 'SimpleValue'

    render: ->
        {on-remove-click, label} = @.props
        div {class-name: "simple-value"}, 
            span {on-click: on-remove-click}, \×
            span null, label

}