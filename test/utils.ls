{promises:{new-promise}} = require \async-ls
{each, map} = require \prelude-ls
{addons:{TestUtils}, create-class, create-element, DOM:{div, option, span}, find-DOM-node} = require \react/addons
{find-rendered-DOM-component-with-class, scry-rendered-DOM-components-with-class, find-rendered-DOM-component-with-tag, Simulate:{change, click, focus, key-down}} = TestUtils
ReactSelectize = require \../src/index.ls

# create-select :: Select -> Props -> Select
create-select = (select-class, props, children) -->
    TestUtils.render-into-document create-element do 
        select-class
        {
            options: <[apple mango orange grapes banana melon pineapple dates]> |> map ~> label: it, value: it
            placeholder: 'Select a fruit'
        } <<< props
        children

# get-input :: Select -> DOMInput
get-input = (select) -> 
    find-DOM-node find-rendered-DOM-component-with-tag select, \input

# set-input-text :: DOMInput -> String -> Void
set-input-text = (input, text) !-->
    input.value = text
    change input

# get-item-text :: Item -> String
get-item-text = (item) ->
    find-DOM-node find-rendered-DOM-component-with-tag item, \span .innerHTML

# click-to-open-select-control :: Select -> Void
click-to-open-select-control = (select) !->
    click find-rendered-DOM-component-with-class select, \control

# find-highlighted-option :: Select -> ReactElement
find-highlighted-option = (select) ->
    find-rendered-DOM-component-with-class select, \highlight

# component-with-class-must-not-exist :: ReactElement -> String -> p String
component-with-class-must-not-exist = (tree, class-name) ->
    res, rej <- new-promise
    try 
        find-rendered-DOM-component-with-class tree, class-name
    catch err 
        res true
    rej "component with class-name: (#{class-name}) must not exist"

# click-on-the-document :: a -> Void
click-on-the-document = ->
    click-event = document.create-event \MouseEvents
        ..init-event \click, true, true
    document.dispatch-event click-event

module.exports = {click-on-the-document, create-select, get-input, set-input-text, get-item-text, click-to-open-select-control, find-highlighted-option, component-with-class-must-not-exist}