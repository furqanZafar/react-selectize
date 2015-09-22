require! \assert
require! \./common-tests
{each, map} = require \prelude-ls
{addons:{TestUtils}, create-class, create-element, DOM:{div, option, span}, find-DOM-node} = require \react/addons
{find-rendered-DOM-component-with-class, scry-rendered-DOM-components-with-class, find-rendered-DOM-component-with-tag, Simulate:{change, click, focus, key-down}} = TestUtils
{create-select, get-input, set-input-text, get-item-text, click-to-open-select-control, find-highlighted-option, component-with-class-must-not-exist} = require \./utils
ReactSelectize = require \../src/index.ls

describe "SimpleSelect", ->
    
    create-simple-select = (props = {}, children = []) ->
        create-select ReactSelectize.SimpleSelect, props, children

    common-tests ReactSelectize.SimpleSelect

    specify "the value method must return the current selected value", ->
        select = create-simple-select!
        click-to-open-select-control select
        key-down (get-input select), which: 40
        key-down (get-input select), which: 13
        assert.equal select.value!.label, \mango

    specify "must use value from props instead of state when available", ->
        select  = create-simple-select do 
            value: label: \apple, value: \apple
        click-to-open-select-control select
        [0 til 3] |> each ~> key-down (get-input select), which: 40
        click find-highlighted-option select
        assert.equal select.value!.label, \apple

    specify "must invoke on-value-change when the value (state) is changed", (done) ->
        select = create-simple-select do 
            on-value-change: (value, callback) ~>
                callback!
                assert.equal value.label, \apple
                done!
        click-to-open-select-control select
        click find-highlighted-option select

    specify "must invoke on-value-change when the value (prop) is changed", (done) ->
        select = create-simple-select do 
            value: label: \apple, value: \apple
            on-value-change: (value, callback) ~>
                callback!
                assert.equal value.label, \mango
                done!
        click-to-open-select-control select
        key-down (get-input select), which: 40
        click find-highlighted-option select

    specify "must be able to remove items on pressing backspace", ->
        select = create-simple-select!
        click-to-open-select-control select
        click find-highlighted-option select
        click-to-open-select-control select
        key-down (get-input select), which: 8
        assert.equal typeof select.state.value, \undefined

    specify "selecting the same value must have no effect", ->
        select = create-simple-select!
        click-to-open-select-control select
        click find-highlighted-option select
        click-to-open-select-control select
        click find-highlighted-option select
        assert.equal (get-item-text (find-rendered-DOM-component-with-class select, \simple-value)), \apple

    specify "typing in the search field must deselect current value", ->
        select = create-simple-select!
        click-to-open-select-control select
        click find-highlighted-option select
        click-to-open-select-control select
        set-input-text (get-input select), \e
        component-with-class-must-not-exist select, \simple-value

    specify "must change value on selecting another item", ->
        select = create-simple-select!
        click-to-open-select-control select
        click find-highlighted-option select
        click-to-open-select-control select
        key-down (get-input select), which: 40
        click find-highlighted-option select
        assert.equal select.value!.label, \mango

    