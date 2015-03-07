{filter, find, map} = require \prelude-ls
# {partition-string} = require \./prelude-extension.ls
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class {

    display-name: 'EmailValue'

    render: ->
        {on-remove-click, first-name, last-name, value} = @.props
        div {class-name: "email-value"}, 
            span {on-click: on-remove-click}, \×
            span {class-name: \name}, "#{first-name} #{last-name}"
            span {class-name: \email}, "<#{value}>"

}