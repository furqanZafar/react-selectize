require! \assert
require! \./common-tests
{each, find, map} = require \prelude-ls
ReactSelectize = require \../src/index.ls

# React
{create-class, create-element, DOM:{div, option, span}} = require \react
{find-DOM-node} = require \react-dom

# TestUtils
{
    find-rendered-DOM-component-with-class
    find-rendered-DOM-component-with-tag
    scry-rendered-DOM-components-with-class
    scry-rendered-DOM-components-with-tag
    Simulate:{change, click, focus}
}:TestUtils = require \react-addons-test-utils

# utils
{create-select, get-input, set-input-text, get-item-text, click-option, click-to-open-select-control, find-highlighted-option, 
component-with-class-must-not-exist, press-backspace, press-escape, press-tab, press-return, press-up-arrow, press-down-arrow, 
press-left-arrow, press-right-arrow, press-command-left, press-command-right} = require \./utils

describe "SimpleSelect", ->
    
    common-tests ReactSelectize.SimpleSelect

    # create-simple-select :: Props -> [ReactElement] -> SimpleSelect
    create-simple-select = (props = {}, children = []) ->
        create-select ReactSelectize.SimpleSelect, props, children

    specify "the value method must return the current selected value", ->
        select = create-simple-select!
        click-to-open-select-control select
        input = get-input select
        press-down-arrow input
        press-return input
        assert.equal select.value!.label, \mango

    specify "must use value from props instead of state when available", ->
        select  = create-simple-select do 
            value: label: \apple, value: \apple
        click-to-open-select-control select
        [0 til 3] |> each -> press-down-arrow (get-input select)
        click-option find-highlighted-option select
        assert.equal select.value!.label, \apple

    specify "must invoke on-value-change when the value (state) is changed", (done) ->
        select = create-simple-select do 
            on-value-change: (value) ~>
                assert.equal value.label, \apple
                done!
        click-to-open-select-control select
        click-option find-highlighted-option select

    specify "must invoke on-value-change when the value (prop) is changed", (done) ->
        select = create-simple-select do 
            value: label: \apple, value: \apple
            on-value-change: (value) ~>
                assert.equal value.label, \mango
                done!
        click-to-open-select-control select
        press-down-arrow (get-input select)
        click-option find-highlighted-option select

    specify "must be able to remove items on pressing backspace", ->
        select = create-simple-select!
        click-to-open-select-control select
        click-option find-highlighted-option select
        click-to-open-select-control select
        press-backspace (get-input select)
        assert.equal typeof select.state.value, \undefined

    specify "selecting the same value must have no effect", ->
        called = 0
        select = create-simple-select do 
            on-value-change: ~> 
                called := called + 1
        click-to-open-select-control select
        set-input-text (get-input select), \e
        click-option find-highlighted-option select
        click-to-open-select-control select
        set-input-text (get-input select), \e
        click-option find-highlighted-option select
        assert called == 1

    specify "typing in the search field must deselect current value", ->
        select = create-simple-select!
        click-to-open-select-control select
        click-option find-highlighted-option select
        click-to-open-select-control select
        set-input-text (get-input select), \e
        component-with-class-must-not-exist select, \simple-value

    specify "must change value on selecting another item", ->
        select = create-simple-select!
        click-to-open-select-control select
        click-option find-highlighted-option select
        click-to-open-select-control select
        press-down-arrow (get-input select)
        click-option find-highlighted-option select
        assert.equal select.value!.label, \mango

    specify "must be able to block default backspace action", ->
        {refs:{select}} = TestUtils.render-into-document create-element create-class do
            render: ->
                create-element do 
                    ReactSelectize.SimpleSelect
                    ref: \select
                    value: @state.value 
                    options: 
                        * label: \apple, value: \apple
                        * label: \banana, value: \banana
                        * label: \mango, value: \mango
                    on-value-change: (value) ~>
                        if !!value 
                            @set-state {value}
            get-initial-state: -> value: undefined
        click-to-open-select-control select
        click-option find-highlighted-option select
        click-to-open-select-control select
        press-backspace get-input select
        find-rendered-DOM-component-with-class select, \simple-value

    specify "selected value must be displayed as search text when props.editable is true ", ->
        select = create-simple-select do 
            editable: (.label)
        click-to-open-select-control select
        click-option find-highlighted-option select
        click-to-open-select-control select
        component-with-class-must-not-exist select, \simple-value
        assert.equal (get-input select).value, \apple

    specify "must be able to select another value when props.default-value is defined", ->
        select = create-simple-select do 
            default-value: label: \mango, value: \mango
        click-to-open-select-control select
        assert.equal select.value!.label. \mango
        set-input-text (get-input select), \apple
        click-option find-highlighted-option select
        assert.equal select.value!.label. \apple

    specify "form serialization", ->
        select = create-simple-select do 
            name: \test
        click-to-open-select-control select
        click-option find-highlighted-option select
        {value} = scry-rendered-DOM-components-with-tag select, \input
            |> find (.type == \hidden)
        assert \apple == value

    specify "must blur on pressing return key on an empty list of options", (done) ->
        state = on-enter-invoked: false
        select = create-simple-select!
        click-to-open-select-control select
        input = get-input select
        set-input-text input, "some random text"
        press-return input
        <~ set-timeout _, 25
        component-with-class-must-not-exist \react-selectize-dropdown
        assert select.state.search == ""
        done!
