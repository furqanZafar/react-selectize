require! \assert
require! \jsdom
global <<< 
    document: jsdom.jsdom '<!doctype html><html><body></body></html>'
    navigator: user-agent: \JSDOM
    window: document.parent-window
{each, map} = require \prelude-ls
{addons:{TestUtils}, create-class, create-element, DOM:{div, option, span}, find-DOM-node} = require \react/addons
{find-rendered-DOM-component-with-class, scry-rendered-DOM-components-with-class, find-rendered-DOM-component-with-tag, Simulate:{change, click, focus, key-down}} = TestUtils
ReactSelectize = require \../src/index.ls

# create-simple-select :: Props -> SimpleSelect
create-simple-select = (props = {}, children) ->
    TestUtils.render-into-document create-element do 
        ReactSelectize.SimpleSelect
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

# open-select :: Select -> Void
open-select = (select) !->
    click find-rendered-DOM-component-with-class select, \control

# find-highlighted-option :: Select -> ReactElement
find-highlighted-option = (select) ->
    find-rendered-DOM-component-with-class select, \highlight

describe "SimpleSelect", ->

    specify "empty select must have placeholder", ->
        select = create-simple-select!
        find-rendered-DOM-component-with-class select, \placeholder

    specify "non empty select must not have placeholder", (done) ->
        {refs}:select = create-simple-select!
        input = find-DOM-node refs.select.refs.search
            ..value = \test
        change input
        try 
            find-rendered-DOM-component-with-class select, \placeholder
        catch err 
            return done!
        throw "placeholder must not be visible when search.length > 0"

    specify "must default the list of options to an empty list", ->
        select = create-simple-select options: undefined
        open-select select
        find-rendered-DOM-component-with-class select, \dropdown

    specify "must show the list of options on click", ->
        select = create-simple-select!
        open-select select
        find-rendered-DOM-component-with-class select, \dropdown

    specify "input must autosize to fit its contents", ->
        {refs}:select = create-simple-select do 
            autosize: -> 100
        input = get-input select
        set-input-text input, \text
        assert.equal input.style.width, \100px

    specify "must open options dropdown on search change", ->
        select = create-simple-select!
        set-input-text (get-input select), \text
        find-rendered-DOM-component-with-class select, \dropdown

    specify "must filter options list on search change", ->
        select = create-simple-select!
        set-input-text (get-input select), \l
        options = scry-rendered-DOM-components-with-class select, \simple-option
        assert.equal options.length, 3
        assert.equal (get-item-text options.0), \apple

    specify "must highlight the first option on open", ->
        select = create-simple-select!
        open-select select
        assert.equal (get-item-text find-highlighted-option select), \apple

    specify "must be able to navigate options using down arrow key", ->
        select = create-simple-select!
        open-select select
        key-down (get-input select), which: 40
        assert.equal (get-item-text find-highlighted-option select), \mango

    specify "must be able to navigate options using up arrow key", ->
        select = create-simple-select!
        open-select select
        [0 til 3] |> each ~> key-down (get-input select), which: 40
        key-down (get-input select), which: 38
        assert.equal (get-item-text find-highlighted-option select), \orange

    specify "must select highlighted option on pressing return key", ->
        select = create-simple-select!
        open-select select
        key-down (get-input select), which: 13
        assert.equal (get-item-text find-rendered-DOM-component-with-class select, \simple-value), \apple

    specify "must select option on click", ->
        select = create-simple-select!
        open-select select
        click find-highlighted-option select
        assert.equal (get-item-text find-rendered-DOM-component-with-class select, \simple-value), \apple

    specify "the value method must return the current selected value", ->
        select = create-simple-select!
        open-select select
        key-down (get-input select), which: 40
        key-down (get-input select), which: 13
        assert.equal select.value!.label, \mango

    specify "must use value from props instead of state when available", ->
        select  = create-simple-select do 
            value: label: \apple, value: \apple
        open-select select
        [0 til 3] |> each ~> key-down (get-input select), which: 40
        click find-highlighted-option select
        assert.equal select.value!.label, \apple

    specify "must use search from props instead of state when available", ->
        select  = create-simple-select do 
            search: \orange
        set-input-text (get-input select), \apple
        click find-highlighted-option select
        assert.equal select.value!.label, \orange

    specify "must invoke on-value-change when the value (state) is changed", (done) ->
        select = create-simple-select do 
            on-value-change: (value, callback) ~>
                callback!
                assert.equal value.label, \apple
                done!
        open-select select
        click find-highlighted-option select

    specify "must invoke on-search-change when the search (state) is changed", (done) ->
        select = create-simple-select do 
            on-search-change: (search, callback) ->
                callback!
                assert.equal search, \test
                done!
        set-input-text (get-input select), \test

    specify "must invoke on-value-change when the value (prop) is changed", (done) ->
        select = create-simple-select do 
            value: label: \apple, value: \apple
            on-value-change: (value, callback) ~>
                callback!
                assert.equal value.label, \mango
                done!
        open-select select
        key-down (get-input select), which: 40
        click find-highlighted-option select

    specify "must invoke on-search-change when the search (prop) is changed", (done) ->
        select = create-simple-select do 
            search: ""
            on-search-change: (search, callback) ->
                callback!
                assert.equal search, \test
                done!
        set-input-text (get-input select), \test

    specify "must be able to remove items on pressing backspace", ->
        select = create-simple-select!
        open-select select
        click find-highlighted-option select
        open-select select
        key-down (get-input select), which: 8
        assert.equal typeof select.state.value, \undefined

    specify "must restore search on pressing backspace", ->
        select = create-simple-select do 
            restore-on-backspace: -> it.label.substr 0, it.label.length - 1
        open-select select
        click find-highlighted-option select
        open-select select
        key-down (get-input select), which: 8
        assert.equal (get-input select).value, \appl

    specify "must create new item from search", ->
        select = create-simple-select do 
            create-from-search: (options, search) ->
                return null if search.length == 0 or search in map (.label), options
                label: search, value: search 
        set-input-text (get-input select), \test
        assert.equal (get-item-text find-highlighted-option select), "Add test ..."

    specify "must not be interactive when disabled", (done) ->
        select = create-simple-select do 
            disabled: true
        open-select select
        try 
            find-rendered-DOM-component-with-class select, \dropdown
        catch err 
            return done!
        throw "dropdown must not be visible when search is disabled"

    specify "must be able to render custom option", ->
        select = create-simple-select do 
            render-option: ({label, value}) ->
                div class-name: \custom-option,
                    span null, label
        open-select select
        assert.equal (scry-rendered-DOM-components-with-class select, \custom-option).length > 0, true

    specify "must be able to render custom value", ->
        select = create-simple-select do 
            render-value: ({label, value}) ->
                div class-name: \custom-value,
                    span null, label
        open-select select
        click find-highlighted-option select
        find-rendered-DOM-component-with-class select, \custom-value

    specify "must be able to create option groups", ->
        select = create-simple-select do 
            groups: [{group-id: \asia, title: \Asia}, {group-id: \europe, title: \Europe}]
            options: 
                * label: \Korea
                  value: \Korea
                  group-id: \asia
                * label: \England
                  value: \England
                  group-id: \europe
        open-select select
        assert.equal (scry-rendered-DOM-components-with-class select, \simple-group-title).length, 2

    specify "unselectable options must not be selectable", (done) ->
        select = create-simple-select do 
            options: 
                * label: \apple
                  value: \apple
                  selectable: false
                ...
        open-select select
        try 
            find-rendered-DOM-component-with-class select, \highlight
        catch err 
            return done!
        throw "unselectable option must not be highlighted"

    specify "selecting the same value must have no effect", ->
        select = create-simple-select!
        open-select select
        click find-highlighted-option select
        open-select select
        click find-highlighted-option select
        assert.equal (get-item-text (find-rendered-DOM-component-with-class select, \simple-value)), \apple

    specify "typing in the search field must deselect current value", (done) ->
        select = create-simple-select!
        open-select select
        click find-highlighted-option select
        open-select select
        set-input-text (get-input select), \e
        try 
            find-rendered-DOM-component-with-class select, \simple-value
        catch err 
            return done!
        throw "typing a character in the search field must deselect current value"

    specify "must change value on selecting another item", ->
        select = create-simple-select!
        open-select select
        click find-highlighted-option select
        open-select select
        key-down (get-input select), which: 40
        click find-highlighted-option select
        assert.equal select.value!.label, \mango

    specify "must apply custom class-name", ->
        select = create-simple-select do 
            class-name: \test
        assert.equal ((find-DOM-node select).class-name.index-of \test) > -1, true

    specify "must close options dropdown on pressing the escape key", (done) ->
        select = create-simple-select!
        open-select select
        key-down (get-input select), which: 27
        try 
            find-rendered-DOM-component-with-class select, \dropdown
        catch err 
            return done!
        throw "dropdown must not be visible after pressing the escape key"

    specify "must render custom dom for 'no results found'", ->
        select = create-simple-select do 
            render-no-results-found: -> div class-name: \custom-no-results-found, "no results found"
        open-select select
        set-input-text (get-input select), \test-case
        find-rendered-DOM-component-with-class select, \custom-no-results-found

    specify "must clear search text on blur", ->
        select = create-simple-select!
        open-select select
        set-input-text (get-input select), \test 
        key-down (get-input select), which: 9
        assert.equal select.state.search, ""

    specify "on-focus must default to noop", ->
        models = create-simple-select!
        focus (get-input models)

    specify "must call on-focus on open", (done) ->
        models = create-simple-select do 
            on-focus: -> done!
        focus (get-input models)

    specify "must use children as options when props.options is undefined", ->
        children = 
            * option {key: \1, value: \1}, \1
            * option {key: \2, value: \2}, \2
            * option {key: \3, value: \3}, \3
            ...
        select = TestUtils.render-into-document create-element do 
            ReactSelectize.SimpleSelect 
            {}
            children
        open-select select
        key-down (get-input select), which: 40
        click find-highlighted-option select
        assert.equal select.value!.label, \2

    specify "highlight-first-selectable-option method must highlight the first selectable option", ->
        select = create-simple-select!
        open-select select
        [0 til 5] |> each -> key-down (get-input select), which: 40
        select.highlight-first-selectable-option!
        assert.equal (get-item-text find-highlighted-option select), \apple

    specify "highlight-first-selectable-option must not open the select", (done) ->
        select = create-simple-select!
        select.highlight-first-selectable-option!
        try 
            find-rendered-DOM-component-with-class select, \dropdown
        catch err 
            return done!
        throw "dropdown must not be visible when search is disabled"

    specify "must highlight the second option, when creating options from search & search results are non empty", ->
        select = create-simple-select do 
            create-from-search: (, search) -> label: search, value: search
        set-input-text (get-input select), \a
        click find-highlighted-option select
        assert.equal select.value!.label, \apple

    specify "must highlight the first option, when creating options from search & the search results are unselectable", ->
        select = create-simple-select do 
            options: <[apple mango grapes banana kiwi dates pie]> |> map ~> label: it, value: it, selectable: false
            create-from-search: (, search) -> label: search, value: search
        set-input-text (get-input select), \app
        assert.equal (get-item-text find-highlighted-option select), "Add app ..."