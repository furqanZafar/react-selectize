require! \assert
require! \./common-tests
{each, map, Str} = require \prelude-ls
ReactSelectize = require \../src/index.ls

# React
{create-class, create-element, DOM:{div, option, span}, find-DOM-node} = require \react
{find-DOM-node} = require \react-dom

# TestUtils
{find-rendered-DOM-component-with-class, scry-rendered-DOM-components-with-class, 
find-rendered-DOM-component-with-tag, Simulate:{change, click, focus, key-down}}:TestUtils = require \react-addons-test-utils

# utils
{create-select, get-input, set-input-text, get-item-text, click-to-open-select-control, find-highlighted-option, 
component-with-class-must-not-exist, press-backspace, press-escape, press-tab, press-return, press-up-arrow, press-down-arrow, press-left-arrow, 
press-right-arrow, press-command-left, press-command-right} = require \./utils

describe "MultiSelect", ->
    
    # create-multi-select :: Props -> [ReactElement] -> MultiSelect
    create-multi-select = (props = {}, children = []) ->
        create-select ReactSelectize.MultiSelect, props, children

    common-tests ReactSelectize.MultiSelect

    specify "the values method must return the current selected values", ->
        select = create-multi-select!
        click-to-open-select-control select
        press-down-arrow (get-input select)
        press-return (get-input select)
        press-return (get-input select)
        assert.equal select.values!.length, 2
        assert.equal select.values!.0.label, \mango

    specify "must use values from props instead of state when available", ->
        select  = create-multi-select do 
            values: 
                * label: \apple, value: \apple
                * label: \mango, value: \mango
                ...
        click-to-open-select-control select
        [0 til 3] |> each ~> press-down-arrow (get-input select)
        click find-highlighted-option select
        assert.equal select.values!.length, 2

    specify "must invoke on-values-change when the value (state) is changed", (done) ->
        select = create-multi-select do 
            on-values-change: (values, callback) ~>
                callback!
                assert.equal values.length, 1
                assert.equal values.0.label, \apple
                done!
        click-to-open-select-control select
        click find-highlighted-option select

    specify "must invoke on-value-change when the value (prop) is changed", (done) ->
        select = create-multi-select do 
            values: 
                * label: \apple, value: \apple
                ...
            on-values-change: (values, callback) ~>
                callback!
                assert.equal values.length, 2
                assert.equal values.1.label, \orange
                done!
        click-to-open-select-control select
        press-down-arrow (get-input select)
        click find-highlighted-option select

    specify "must use anchor from props instead of state when available", ->
        select  = create-multi-select do 
            anchor: undefined
        click-to-open-select-control select
        [0 til 4] |> each ~> click find-highlighted-option select
        assert.equal do 
            select.values! 
                |> map (.label)
                |> Str.join \,
            "grapes,orange,mango,apple"

    specify "must invoke on-anchor-change on pressing left/right arrow keys", (done) ->
        left-count = 0
        right-count = 0
        select  = create-multi-select do 
            on-anchor-change: (anchor, callback) ->
                callback!
                if anchor?.label == \orange
                    left-count := left-count + 1
                if anchor?.label == \grapes
                    right-count := right-count + 1
                if left-count == right-count == 2
                    done!
        click-to-open-select-control select
        [0 til 4] |> each ~> click find-highlighted-option select
        press-left-arrow (get-input select)
        press-right-arrow (get-input select)

    specify "must be able to remove items on pressing backspace", ->
        select = create-multi-select!
        click-to-open-select-control select
        [0 til 3] |> each ~> click find-highlighted-option select
        click-to-open-select-control select
        press-backspace (get-input select)
        assert select.values!.length, 2

    specify "@props.max-values must restrict the maximum selectable values", ->
        select = create-multi-select do 
            max-values: 2
        click-to-open-select-control select
        click find-highlighted-option select
        click find-highlighted-option select
        assert component-with-class-must-not-exist select, \dropdown
        click-to-open-select-control select
        assert component-with-class-must-not-exist select, \dropdown

    specify "command + left/right must position the cursor at the start/end", (done) ->
        start-count = 0
        end-count = 0
        select = create-multi-select do 
            on-anchor-change: (anchor, callback) ->
                if anchor == undefined
                    start-count := start-count + 1
                if anchor?.label == \grapes
                    end-count := end-count + 1
                if start-count == 2 and end-count == 2
                    done!
                callback!
        click-to-open-select-control select
        [0 til 4] |> each -> click find-highlighted-option select
        input = get-input select
        press-command-left input
        press-command-right input

    specify "must close dorpdown when there are no more options left to select", ->
        select = create-multi-select!
        click-to-open-select-control select
        [0 til 8] |> each ~> click find-highlighted-option select
        component-with-class-must-not-exist select, \dropdown