{DOM:{div}} = require \react
create-react-class = require \create-react-class
{is-equal-to-object} = require \prelude-extension

module.exports = create-react-class do

    # get-default-porps :: () -> Props
    get-default-props: ->
        # item :: Item
        # render-item :: Item -> ReactElement
        # uid :: a
        {}

    # render :: a -> ReactElement
    render: ->
        div do 
            class-name: \value-wrapper
            @props.render-item @props.item

    # should-component-update :: Props -> Boolean
    should-component-update: (next-props) ->
        !(next-props?.uid `is-equal-to-object` @props?.uid)