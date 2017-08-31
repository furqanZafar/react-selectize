ace = require \brace
require \brace/ext/language_tools
require \brace/ext/searchbox
require \brace/mode/javascript
require \brace/mode/jsx
require \brace/mode/livescript
require \brace/theme/chrome
{each} = require \prelude-ls
{div} = require \react-dom-factories
create-react-class = require \create-react-class

module.exports = create-react-class {

    display-name: \AceEditor

    # get-default-props :: a -> Void
    get-default-props: ->
        # width: 400
        # height: 300
        class-name: ""
        editor-id: "editor_#{Date.now!}"
        mode: \ace/mode/livescript
        # on-change :: String -> Void
        on-change: ((value) !->) 
        theme: \ace/theme/chrome
        value: ""
        wrap: false

    # render :: a -> ReactElement
    render: ->
        div do 
            id: @props.editor-id
            class-name: @props.class-name
            ref: \editor
            style: 
                width: @props.width
                height: @props.height

    # component-did-mount :: a -> Void
    component-did-mount: !->
        editor = ace.edit @props.editor-id
            ..on \change, (, editor) ~> @props.on-change editor.get-value!
            ..set-options enable-basic-autocompletion: true 
            ..set-options max-lines: Infinity if typeof @props.height == \undefined
            ..set-show-print-margin false
        (@props?.commands ? []) |> each ~> editor.commands.add-command it
        @process-props @props

    # component-did-update :: Props -> Void
    component-did-update: (prev-props) !->
        editor = ace.edit @props.editor-id
        editor.resize! if (prev-props.width != @props.width) or (prev-props.height != @props.height)

    # component-will-receive-props :: Props -> Void
    component-will-receive-props: (props) !->
        @process-props props

    # process-props :: Props -> Void
    process-props: ({commands, editor-id, mode, theme, value, wrap}:props?) !->
        editor = ace.edit editor-id
            ..get-session!.set-mode mode if typeof mode != \undefined
            ..get-session!.set-use-wrap-mode wrap if typeof wrap != \undefined
            ..set-theme theme if typeof theme != \undefined
            ..set-value value, -1 if value != editor.get-value!
}