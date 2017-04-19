{create-factory, DOM:{path}} = require \react
create-react-class = require \create-react-class
SvgWrapper = create-factory require \./SvgWrapper

module.exports = create-react-class do

    # render :: a -> ReactElement
    render: ->
        SvgWrapper do 
            class-name: \react-selectize-reset-button
            style: 
                width: 8
                height: 8
            path d: "M0 0 L8 8 M8 0 L 0 8"