{promises:{new-promise}} = require \async-ls
{map} = require \prelude-ls
{create-element} = require \react
{find-DOM-node} = require \react-dom
{
    find-rendered-DOM-component-with-class
    find-rendered-DOM-component-with-tag
    Simulate:{change, click, key-down, mouse-down}
}:TestUtils = require \react-dom/test-utils

# create-select :: Select -> Props -> Select
export create-select = (select-class, props, children) -->
    TestUtils.render-into-document create-element do 
        select-class
        {
            options: <[apple mango orange grapes banana melon pineapple dates]> 
                |> map ~> label: it, value: it
            placeholder: 'Select a fruit'
        } <<< props
        children

# get-input :: Select -> DOMInput
export get-input = (select) -> 
    find-DOM-node do 
        find-rendered-DOM-component-with-class select, \resizable-input

# get-item-text :: Item -> String
export get-item-text = (item) ->
    (item.get-elements-by-tag-name \span).0.innerHTML

export click-option = (option-element, callback) ->
    mouse-down option-element
    event = document.create-event 'MouseEvents'
        ..init-mouse-event \mouseup
    window.dispatch-event event

# click-to-open-select-control :: Select -> Void
export click-to-open-select-control = (select) !->
    mouse-down find-rendered-DOM-component-with-class select, \react-selectize-control

# click-on-the-document :: a -> Void
export click-on-the-document = ->
    click-event = document.create-event \MouseEvents
        ..init-event \click, false, true
    document.body.dispatch-event click-event

# component-with-class-must-not-exist :: ReactElement -> String -> p String
export component-with-class-must-not-exist = (tree, class-name) ->
    res, rej <- new-promise
    try 
        find-rendered-DOM-component-with-class tree, class-name
    catch err 
        res true
    rej "component with class-name: (#{class-name}) must not exist"

# find-highlighted-option :: Select -> ReactElement
export find-highlighted-option = (select) ->
    find-rendered-DOM-component-with-class select, \highlight

# press-backspace :: ReactElement -> Void
export press-backspace = !-> key-down it, which: 8

# press-escape :: ReactElement -> Void
export press-escape = !-> key-down it, which: 27

# press-escape :: ReactElement -> Void
export press-tab = !-> key-down it, which: 9

# press-return :: ReactElement -> Void
export press-return = !-> key-down it, which: 13

# press-up-arrow :: ReactElement -> Void
export press-up-arrow = !-> key-down it, which: 38

# press-down-arrow :: ReactElement -> Void
export press-down-arrow = !-> key-down it, which: 40

# press-left-arrow :: ReactElement -> Void
export press-left-arrow = !-> key-down it, which: 37

# press-right-arrow :: ReactElement -> Void
export press-right-arrow = !-> key-down it, which: 39

# press-command-left :: ReactElement -> Void
export press-command-left = !-> key-down it, which: 37, meta-key: true

# press-command-right :: ReactElement -> Void
export press-command-right = !-> key-down it, which: 39, meta-key: true

# set-input-text :: DOMInput -> String -> Void
export set-input-text = (input, text) !-->
    input.value = text
    change input