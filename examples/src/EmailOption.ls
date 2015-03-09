{filter, find, map} = require \prelude-ls
# {partition-string} = require \./prelude-extension.ls
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class {

    display-name: 'EmailOption'

    statics: {

        filter: (list, search) ->            
            filtered-list = list
                |> filter ({first-name, last-name}?) -> ("#{first-name} #{last-name}".to-lower-case!.index-of search.to-lower-case!) > -1

    }

    render: ->
        {on-click, on-mouse-over, on-mouse-out, focused, index, first-name, last-name, value} = @.props
        div do 
            {
                class-name: "email-option #{if focused then \focused else ''}"
                on-click
                on-mouse-over
                on-mouse-out
            }
            div {class-name: \name}, "#{first-name} #{last-name}"
            div {class-name: \email}, value

}
