{div} = require \react-dom-factories
create-react-class = require \create-react-class

# used to detect when the dropdown has been added/removed from dom, 
# so we can adjust the height of the parent element
module.exports = create-react-class do

    # get-default-props :: () -> Props
    get-default-props: ->
        class-name: ""
        on-height-change: (!->) # Number -> Void

    # render :: () -> ReactElement
    render: ->
        div do 
            class-name: @props.class-name
            ref: \dropdown
            @props.children

    # component-did-mount :: () -> Void
    component-did-mount: !->
        @props.on-height-change do 
            @refs.dropdown .offset-height

    # component-did-update :: () -> Void
    component-did-update: !->
        @props.on-height-change do 
            @refs.dropdown .offset-height

    # component-will-unmount :: () -> Void
    component-will-unmount: !->
        @props.on-height-change 0