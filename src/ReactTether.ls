React = require \react
{render, unmount-component-at-node} = require \react-dom
Tether = require \tether

class ReactTether extends React.PureComponent

    # get-default-props :: () -> Props
    @default-props =
        # target :: () -> DOMElement (invoked on component-did-mount)
        # options :: object (passed to Tether instance)
        # parent-element :: () -> DOMElement
        parent-element: -> document.body

    # render :: () -> ReactElement
    render: -> null

    # init-tether :: Props -> Void
    init-tether: (props) !->
        @node = document.create-element \div
        @props.parent-element!.append-child @node
        @tether = new Tether {
            element: @node
            target: props.target!
        } <<< props.options
        render props.children, @node, ~> @tether.position!

    # destroy-tether :: () -> Void
    destroy-tether: !->
        
        # destroy tether instance
        if @tether
            @tether.destroy!

        # remove div
        if @node
            unmount-component-at-node @node
            @node.parent-element.remove-child @node

        # delete both from memory
        @node = @tether = undefined

    # component-did-mount :: () -> Void
    component-did-mount: !-> 
        if @props.children
            @init-tether @props

    # component-will-receive-props :: Props -> Void
    component-will-receive-props: (new-props) !->
        if @props.children and !new-props.children
            @destroy-tether!

        else if new-props.children and !@props.children
            @init-tether new-props

        else if new-props.children
            @tether.set-options { 
                element: @node
                target: new-props.target!
            } <<< new-props.options
            render new-props.children, @node, ~> @tether.position!

    # component-will-unmount :: () -> Void
    component-will-unmount: !-> @destroy-tether!

module.exports = ReactTether