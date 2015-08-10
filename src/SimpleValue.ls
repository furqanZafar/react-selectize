{DOM:{div, span}}:React = require \react

module.exports = React.create-class do

    display-name: \SimpleValue

    render: ->

        {on-remove-click, label} = @props

        div {class-name: \simple-value},
            span {on-click: on-remove-click}, \×
            span null, label

