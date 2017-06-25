{div} = require \react-dom-factories
create-react-class = require \create-react-class
{is-equal-to-object} = require \prelude-extension
{cancel-event} = require \./utils

# OptionWrapper & ValueWrapper are used for optimizing performance 
module.exports = create-react-class do

    # get-default-porps :: () -> Props
    get-default-props: ->
        # item :: Item
        # on-click :: Event -> Void
        # on-mouse-move :: Event -> Void
        # on-mouse-over :: Event -> Void
        # render-item :: Item -> ReactElement
        # highlight :: Boolean
        # selectable :: Bolean
        # uid :: a
        {}

    # render :: a -> ReactElement
    render: ->
        div do
            class-name: "option-wrapper #{if !!@props.highlight then 'highlight' else ''}"

            # mimic the same behaviour as that of an html select element
            # on-mouse-down :: Event -> ()
            on-mouse-down: (e) ~>
                
                # listener :: Event -> ()
                listener = (e) ~>
                    @props.on-click e
                    window.remove-event-listener \mouseup, listener

                window.add-event-listener \mouseup, listener
                cancel-event e

            on-mouse-move: @props.on-mouse-move
            on-mouse-out: @props.on-mouse-out
            on-mouse-over: @props.on-mouse-over
            @props.render-item @props.item

    # should-component-update :: Props -> Boolean
    should-component-update: (next-props) ->
        (!(next-props?.uid `is-equal-to-object` @props?.uid)) or 
        (next-props?.highlight != @props?.highlight) or 
        (next-props?.selectable != @props?.selectable)
