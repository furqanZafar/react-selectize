{DOM:{div, span}}:React = require \react

module.exports = React.create-class do

    display-name: 'EmailValue'

    render: ->
        {on-remove-click, first-name, last-name, value} = @.props
        div {class-name: "email-value"}, 
            span {on-click: on-remove-click}, \×
            span {class-name: \name}, "#{first-name} #{last-name}"
            span {class-name: \email}, "<#{value}>"

