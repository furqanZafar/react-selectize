{create-class, create-factory, DOM:{path}} = require \react
SvgWrapper = create-factory require \./SvgWrapper

module.exports = create-class do 

    # get-default-props :: () -> Props
    get-default-props: ->
        open: false
        flipped: false

    # render :: a -> ReactElement
    render: ->
        SvgWrapper do 
            class-name: \react-selectize-arrow
            style: 
                width: 10
                height: 8
            path d: 
                | (@props.open and !@props.flipped) or (!@props.open and @props.flipped) => "M0 6 L5 1 L10 6 Z" 
                | _ => "M0 1 L5 6 L10 1 Z"