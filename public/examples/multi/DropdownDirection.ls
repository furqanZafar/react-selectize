create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select fruits"
            dropdown-direction: @state.dropdown-direction
            ref: \select
    
    # get-initial-state :: a -> UIState
    get-initial-state: ->    
        dropdown-direction: 1

    # component-did-mount :: a -> Void
    component-did-mount: !->
        @on-scroll-change = ~>
            {offset-top} = find-DOM-node @refs.select
            screen-top = offset-top - (window.scroll-y ? document.document-element.scroll-top)
            dropdown-direction = if window.inner-height - screen-top < 215 then -1 else 1
            if dropdown-direction != @state.dropdown-direction
                @set-state {dropdown-direction}
        window.add-event-listener \scroll, @on-scroll-change

    # component-will-unmount :: a -> Void
    component-will-unmount: !->
        window.remove-event-listener \scroll, @on-scroll-change
                
render (React.create-element Form, null), mount-node