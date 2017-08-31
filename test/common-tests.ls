require! \assert
{each, map} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension

# React
{create-element} = require \react
{div, input, option, span} = require \react-dom-factories
{find-DOM-node, render, unmount-component-at-node} = require \react-dom

# TestUtils
{
    find-rendered-DOM-component-with-class
    find-rendered-DOM-component-with-tag
    scry-rendered-DOM-components-with-class
    scry-rendered-DOM-components-with-tag
    key-down
    Simulate:{blur, change, click, focus, key-down, mouse-down, mouse-over, mouse-out, mouse-move}
}:TestUtils = require \react-dom/test-utils

# utils
{create-select, get-input, set-input-text, get-item-text, click-option, click-to-open-select-control, 
click-on-the-document, find-highlighted-option, component-with-class-must-not-exist, press-backspace, 
press-escape, press-tab, press-return, press-up-arrow, press-down-arrow, press-left-arrow, press-right-arrow, 
press-command-left}:utils = require \./utils

# :: ReactClass -> Void
module.exports = (select-class) !->

    # create-select :: Props -> [ReactElement] -> Select
    create-select = (props = {}, children = []) ->
        utils.create-select select-class, props, children

    specify "empty select must have placeholder", ->
        select = create-select!
        find-rendered-DOM-component-with-class select, \react-selectize-placeholder

    specify "non empty select must not have placeholder", ->
        {search-element}:select = create-select { search: \test }
        component-with-class-must-not-exist select, \react-selectize-placeholder

    specify "must default the list of options to an empty list", ->
        select = create-select options: undefined
        click-to-open-select-control select
        find-rendered-DOM-component-with-class select, \dropdown-menu

    specify "must show the list of options on click", ->
        select = create-select!
        click-to-open-select-control select
        find-rendered-DOM-component-with-class select, \dropdown-menu

    specify "must open options dropdown on search change", ->
        select = create-select!
        set-input-text (get-input select), \text
        find-rendered-DOM-component-with-class select, \dropdown-menu

    specify "must filter options list on search change", ->
        select = create-select!
        set-input-text (get-input select), \l
        options = scry-rendered-DOM-components-with-class select, \simple-option
        assert.equal options.length, 3
        assert.equal (get-item-text options.0), \apple

    specify "must highlight the first option on open", ->
        select = create-select!
        click-to-open-select-control select
        assert.equal (get-item-text find-highlighted-option select), \apple

    specify "must be able to navigate options using down arrow key", ->
        select = create-select!
        click-to-open-select-control select
        press-down-arrow (get-input select)
        assert.equal (get-item-text find-highlighted-option select), \mango

    specify "must be able to navigate options using up arrow key", ->
        select = create-select!
        click-to-open-select-control select
        input = get-input select
        [0 til 3] |> each ~> press-down-arrow input
        press-up-arrow input
        assert.equal (get-item-text find-highlighted-option select), \orange

    specify "must select highlighted option on pressing return key", ->
        select = create-select!
        click-to-open-select-control select
        press-return (get-input select)
        assert.equal (get-item-text find-rendered-DOM-component-with-class select, \simple-value), \apple

    specify "must select option on click", ->
        select = create-select!
        click-to-open-select-control select
        click-option find-highlighted-option select
        assert.equal (get-item-text find-rendered-DOM-component-with-class select, \simple-value), \apple

    specify "must use search from props instead of state when available", ->
        select = create-select do 
            search: \orange
        input = get-input select
        set-input-text input, \apple
        assert.equal input.value, \orange

    specify "must invoke on-search-change when the search (state) is changed", (done) ->
        select = create-select do 
            on-search-change: (search) ->
                assert.equal search, \test
                done!
        set-input-text (get-input select), \test

    specify "must invoke on-search-change when the search (prop) is changed", (done) ->
        select = create-select do 
            search: ""
            on-search-change: (search) ->
                assert.equal search, \test
                done!
        set-input-text (get-input select), \test

    specify "must restore search on pressing backspace", ->
        select = create-select do 
            restore-on-backspace: -> it.label.substr 0, it.label.length - 1
        click-to-open-select-control select
        click-option find-highlighted-option select
        click-to-open-select-control select
        press-backspace (get-input select)
        assert.equal (get-input select).value, \appl

    specify "must create new item from search", ->
        select = create-select do 
            create-from-search: (..., search) -> label: search, value: search 
        set-input-text (get-input select), \test
        assert.equal (get-item-text find-highlighted-option select), "Add test ..."

    specify "must not be interactive when disabled", ->
        select = create-select do 
            disabled: true
        click-to-open-select-control select
        component-with-class-must-not-exist select, \dropdown-menu

    specify "must be able to render custom option", ->
        select = create-select do 
            render-option: ({label, value}) ->
                div class-name: \custom-option,
                    span null, label
        click-to-open-select-control select
        assert.equal (scry-rendered-DOM-components-with-class select, \custom-option).length > 0, true

    specify "must be able to render custom value", ->
        select = create-select do 
            render-value: ({label, value}) ->
                div class-name: \custom-value,
                    span null, label
        click-to-open-select-control select
        click-option find-highlighted-option select
        find-rendered-DOM-component-with-class select, \custom-value

    specify "must be able to create option groups", ->
        select = create-select do 
            groups: [{group-id: \asia, title: \Asia}, {group-id: \europe, title: \Europe}]
            options: 
                * label: \Korea
                  value: \Korea
                  group-id: \asia
                * label: \England
                  value: \England
                  group-id: \europe
        click-to-open-select-control select
        assert.equal (scry-rendered-DOM-components-with-class select, \simple-group-title).length, 2

    specify "unselectable options must not be selectable", ->
        select = create-select do 
            options: 
                * label: \apple
                  value: \apple
                  selectable: false
                ...
        click-to-open-select-control select
        component-with-class-must-not-exist select, \highlight

    specify "must apply custom class-name", ->
        select = create-select do 
            class-name: \test
        assert.equal ((find-DOM-node select).class-name.index-of \test) > -1, true

    specify "must deselect current value on pressing escape key", ->
        select = create-select!
        click-to-open-select-control select
        click-option find-highlighted-option select
        press-escape (get-input select)
        component-with-class-must-not-exist select, \simple-option

    specify "must close options dropdown on pressing the escape key", ->
        select = create-select!
        click-to-open-select-control select
        press-escape (get-input select)
        component-with-class-must-not-exist select, \dropdown-menu

    specify "must render custom dom for 'no results found'", ->
        select = create-select do 
            render-no-results-found: -> div class-name: \custom-no-results-found, "no results found"
        click-to-open-select-control select
        set-input-text (get-input select), \test-case
        find-rendered-DOM-component-with-class select, \custom-no-results-found

    specify "must clear search text on blur", ->
        select = create-select!
        click-to-open-select-control select
        input = get-input select
        set-input-text input, \test 
        blur input
        assert.equal select.state.search, ""

    specify "on-focus must default to noop", ->
        models = create-select!
        focus (get-input models)

    specify "must call on-focus on open", (done) ->
        models = create-select do 
            on-focus: -> done!
        focus (get-input models)

    specify "must use children (single object) as options when props.options is undefined", ->
        children = option {key: \1, value: \1}, \1
        select = TestUtils.render-into-document (create-element select-class, {}, children)
        click-to-open-select-control select
        assert.equal (scry-rendered-DOM-components-with-class select, \simple-option).length, 1

    specify "must use children (array) as options when props.options is undefined", ->
        children = 
            * option {key: \1, value: \1}, \1
            * option {key: \2, value: \2}, \2
            * option {key: \3, value: \3}, \3
            ...
        select = TestUtils.render-into-document (create-element select-class, {}, children)
        click-to-open-select-control select
        assert.equal (scry-rendered-DOM-components-with-class select, \simple-option).length, 3

    specify "highlight-first-selectable-option method must highlight the first selectable option", ->
        select = create-select!
        click-to-open-select-control select
        press-up-arrow (get-input select)
        select.highlight-first-selectable-option!
        assert.equal (get-item-text find-highlighted-option select), \apple

    specify "highlight-first-selectable-option must not open the select", ->
        select = create-select!
        select.highlight-first-selectable-option!
        component-with-class-must-not-exist select, \dropdown-menu

    specify "must highlight the second option, when creating options from search & search results are non empty", ->
        select = create-select do 
            create-from-search: (..., search) -> label: search, value: search
        set-input-text (get-input select), \a
        assert.equal (get-item-text find-highlighted-option select), \apple

    specify "must highlight the first option, when creating options from search & the search results are unselectable", ->
        select = create-select do 
            options: <[apple mango grapes banana kiwi dates pie]> |> map ~> label: it, value: it, selectable: false
            create-from-search: (..., search) -> label: search, value: search
        set-input-text (get-input select), \app
        assert.equal (get-item-text find-highlighted-option select), "Add app ..."

    specify "must flip the dropdown direction when @props.dropdown-direction = -1", ->
        select = create-select do 
            dropdown-direction: -1
        assert.equal (find-DOM-node select .class-name .index-of \flipped) > -1, true

    specify "must hide dropdown on clicking outside the component area", ->
        select = create-select!
        click-to-open-select-control select
        blur get-input select
        component-with-class-must-not-exist select, \dropdown-menu

    specify "must deselect on clicking reset button", ->
        select = create-select!
        click-to-open-select-control select
        click-option find-highlighted-option select
        click (find-rendered-DOM-component-with-class select, \react-selectize-reset-button)
        component-with-class-must-not-exist \simple-value

    specify "must default to an empty list of options", ->
        select = TestUtils.render-into-document (create-element select-class, {options: null}, [])
        click-to-open-select-control select
        set-input-text (get-input select), \test
        find-rendered-DOM-component-with-class select, \dropdown-menu
        find-rendered-DOM-component-with-class select, \no-results-found
        component-with-class-must-not-exist \simple-option

    specify "setting disabled to true must hide the dropdown and block interactivity", ->
        container = document.create-element \div
        select = render do 
            create-element do 
                select-class
                options: []
            container
        click-to-open-select-control select
        select = render do 
            create-element do 
                select-class
                disabled: true
                options: []
            container
        component-with-class-must-not-exist select, \dropdown-menu

    specify "must work when passed null props and undefined children", ->
        TestUtils.render-into-document do 
            create-element do 
                select-class
                null

    specify "mouseover on an option must highlight it", ->
        select = create-select!
        click-to-open-select-control select
        mouse-over (scry-rendered-DOM-components-with-class select, \simple-option).1
        assert.equal (get-item-text find-highlighted-option select), \mango

    specify "mouseout must reset highlighted option furqan", ->
        select = create-select!
        click-to-open-select-control select
        mouse-out find-highlighted-option select
        component-with-class-must-not-exist select, \highlight

    specify "clicking toggle button must toggle the dropdown", ->
        select = create-select!
        toggle-button = find-rendered-DOM-component-with-class select, \react-selectize-toggle-button
        mouse-down toggle-button
        find-rendered-DOM-component-with-class select, \dropdown-menu
        mouse-down toggle-button
        component-with-class-must-not-exist select, \dropdown-menu

    specify "must wrap around on hitting the boundary", ->
        select = create-select!
        click-to-open-select-control select
        [0 til 8] |> each ~> press-down-arrow (get-input select)
        assert.equal (get-item-text find-highlighted-option select), \apple
        [0 til 8] |> each ~> press-up-arrow (get-input select)
        assert.equal (get-item-text find-highlighted-option select), \apple

    specify "delimiters", ->
        select = create-select do
            delimiters: [186, 188]
        click-to-open-select-control select
        input-element = get-input select
        set-input-text input-element, \app
        key-down input-element, which: 188
        find-rendered-DOM-component-with-class select, \simple-value

    specify "unmount when open", ->
        select = create-select!
        click-to-open-select-control select
        unmount-component-at-node (find-DOM-node select .parent-element)

    specify "must blur on calling the blur method", ->
        select = create-select!
        click-to-open-select-control select
        select.blur!
        component-with-class-must-not-exist \dropdown-menu

    specify "pressing down arrow key on a closed select must open and select the first option", ->
        select = create-select!
        press-down-arrow get-input select
        find-rendered-DOM-component-with-class select, \dropdown-menu
        assert \apple == get-item-text (find-rendered-DOM-component-with-class select, \highlight)

    specify "pressing up arrow key on a closed select must open and select the first option", ->
        select = create-select!
        press-up-arrow get-input select
        find-rendered-DOM-component-with-class select, \dropdown-menu
        assert \apple == get-item-text (find-rendered-DOM-component-with-class select, \highlight)

    specify "must not interfere with command + enter or control + enter", ->
        select = create-select!
        click-to-open-select-control select
        key-down (get-input select), which: 13, meta-key: true
        find-rendered-DOM-component-with-class select, \dropdown-menu

    specify "hide reset button when nothing is selected", ->
        select = create-select!
        component-with-class-must-not-exist select, \react-selectize-reset-button-container

    specify "show reset button when something is selected", ->
        select = create-select!
        click-to-open-select-control select
        click-option find-highlighted-option select
        find-rendered-DOM-component-with-class select, \react-selectize-reset-button-container

    specify "props.hideResetButton must hide reset button", ->
        select = create-select do 
            hide-reset-button: true
        click-to-open-select-control select
        click-option find-highlighted-option select
        component-with-class-must-not-exist select, \react-selectize-reset-button-container

    specify "must use text as default type of search field", ->
        select = create-select!
        input = get-input select
        assert input.type == \text

    specify "must pass props.inputProps to search field", ->
        select = create-select do 
            input-props: { disabled: true, type: \tel }
        input = get-input select
        assert input.disabled == true
        assert input.type == \tel
