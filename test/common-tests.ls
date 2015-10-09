require! \assert
{each, map} = require \prelude-ls

# React
{create-class, create-element, DOM:{div, option, span}} = require \react
{find-DOM-node, render} = require \react-dom

# TestUtils
{find-rendered-DOM-component-with-class, scry-rendered-DOM-components-with-class, 
Simulate:{change, click, focus, key-down, mouse-over, mouse-out, mouse-move}}:TestUtils = require \react-addons-test-utils

# utils
{create-select, get-input, set-input-text, get-item-text, click-to-open-select-control, click-on-the-document, find-highlighted-option, 
component-with-class-must-not-exist, press-backspace, press-escape, press-tab, press-return, press-up-arrow, press-down-arrow, press-left-arrow, 
press-right-arrow, press-command-left, press-command-right}:utils = require \./utils

# :: ReactClass -> Void
module.exports = (select-class) !->

    # create-select :: Props -> [ReactElement] -> Select
    create-select = (props = {}, children = []) ->
        utils.create-select select-class, props, children

    specify "empty select must have placeholder", ->
        select = create-select!
        find-rendered-DOM-component-with-class select, \placeholder

    specify "non empty select must not have placeholder", ->
        {refs}:select = create-select!
        input = find-DOM-node refs.select.refs.search
            ..value = \test
        change input
        component-with-class-must-not-exist select, \placeholder

    specify "must default the list of options to an empty list", ->
        select = create-select options: undefined
        click-to-open-select-control select
        find-rendered-DOM-component-with-class select, \dropdown

    specify "must show the list of options on click", ->
        select = create-select!
        click-to-open-select-control select
        find-rendered-DOM-component-with-class select, \dropdown

    specify "input must autosize to fit its contents", ->
        {refs}:select = create-select do 
            autosize: -> 100
        input = get-input select
        set-input-text input, \text
        assert.equal input.style.width, \100px

    specify "must open options dropdown on search change", ->
        select = create-select!
        set-input-text (get-input select), \text
        find-rendered-DOM-component-with-class select, \dropdown

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
        click find-highlighted-option select
        assert.equal (get-item-text find-rendered-DOM-component-with-class select, \simple-value), \apple

    specify "must use search from props instead of state when available", ->
        select = create-select do 
            search: \orange
        input = get-input select
        set-input-text input, \apple
        assert.equal input.value, \orange

    specify "must invoke on-search-change when the search (state) is changed", (done) ->
        select = create-select do 
            on-search-change: (search, callback) ->
                callback!
                assert.equal search, \test
                done!
        set-input-text (get-input select), \test

    specify "must invoke on-search-change when the search (prop) is changed", (done) ->
        select = create-select do 
            search: ""
            on-search-change: (search, callback) ->
                callback!
                assert.equal search, \test
                done!
        set-input-text (get-input select), \test

    specify "must restore search on pressing backspace", ->
        select = create-select do 
            restore-on-backspace: -> it.label.substr 0, it.label.length - 1
        click-to-open-select-control select
        click find-highlighted-option select
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
        component-with-class-must-not-exist select, \dropdown

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
        click find-highlighted-option select
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
        click find-highlighted-option select
        press-escape (get-input select)
        component-with-class-must-not-exist select, \simple-option

    specify "must close options dropdown on pressing the escape key", ->
        select = create-select!
        click-to-open-select-control select
        press-escape (get-input select)
        component-with-class-must-not-exist select, \dropdown

    specify "must render custom dom for 'no results found'", ->
        select = create-select do 
            render-no-results-found: -> div class-name: \custom-no-results-found, "no results found"
        click-to-open-select-control select
        set-input-text (get-input select), \test-case
        find-rendered-DOM-component-with-class select, \custom-no-results-found

    specify "must clear search text on blur", ->
        select = create-select!
        click-to-open-select-control select
        set-input-text (get-input select), \test 
        press-tab (get-input select)
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
        component-with-class-must-not-exist select, \dropdown

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
        click-on-the-document!
        component-with-class-must-not-exist select, \dropdown

    specify "must deselect on clicking reset button", ->
        select = create-select!
        click-to-open-select-control select
        click find-highlighted-option select
        click (find-rendered-DOM-component-with-class select, \reset)
        component-with-class-must-not-exist \simple-value

    specify "must default to an empty list of options", ->
        select = TestUtils.render-into-document (create-element select-class, {options: null}, [])
        click-to-open-select-control select
        set-input-text (get-input select), \test
        find-rendered-DOM-component-with-class select, \dropdown
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
        component-with-class-must-not-exist select, \dropdown

    specify "must work when passed null props and undefined children", ->
        TestUtils.render-into-document do 
            create-element do 
                select-class
                null

    specify "unmounting the component must remove the click listener", (done) ->
        container = document.create-element \div
        original-remove-event-listener-function = document.remove-event-listener
        document.remove-event-listener = ->
            original-remove-event-listener-function ...
            done!
        render do 
            create-element do 
                select-class
                options: []
            container
        render (div null), container
        document.remove-event-listener = original-remove-event-listener-function

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

    specify "clicking arrow button must toggle the dropdown", ->
        select = create-select!
        arrow = find-rendered-DOM-component-with-class select, \arrow
        click arrow
        find-rendered-DOM-component-with-class select, \dropdown
        click arrow
        component-with-class-must-not-exist select, \dropdown