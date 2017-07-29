{create-factory}:React = require \react
{path} = require \react-dom-factories
SvgWrapper = create-factory require \./SvgWrapper

module.exports = class ResetButton extends React.PureComponent

    # render :: a -> ReactElement
    render: ->
        SvgWrapper do 
            class-name: \react-selectize-reset-button
            style: 
                width: 8
                height: 8
            path d: "M0 0 L8 8 M8 0 L 0 8"