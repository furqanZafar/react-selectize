{filter, find, map} = require \prelude-ls
{DOM:{div, input, span}}:React = require \react

module.exports = React.create-class do

    display-name: 'EmailOption'

    statics:
        filter: (list, search) ->
            filtered-list = list |> filter ({first-name, last-name}?) -> ("#{first-name} #{last-name}".to-lower-case!.index-of search.to-lower-case!) > -1

    render: ->
        {focused, first-name, last-name, value} = @props
        div do 
            class-name: "email-option #{if focused then \focused else ''}"
            div {class-name: \name}, "#{first-name} #{last-name}"
            div {class-name: \email}, value

