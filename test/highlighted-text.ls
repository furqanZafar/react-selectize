require! \assert
require! \../src/HighlightedText
{partition-string} = require \prelude-extension

# React
{addons:{TestUtils}, create-class, create-element, DOM:{div, option, span}, find-DOM-node} = require \react/addons

# TestUtils
{find-rendered-DOM-component-with-class, scry-rendered-DOM-components-with-class, find-rendered-DOM-component-with-tag, Simulate:{change, click, focus, key-down}} = TestUtils

create-highlighted-text = (props = {}) ->
    TestUtils.render-into-document do 
        create-element do 
            HighlightedText
            {
                partitions: partition-string \application, \a
                text: \application
            } <<< props

describe "HighlightedText", ->

    specify "must render partitioned strings", ->
        highlighted-text = create-highlighted-text!
        assert.equal (scry-rendered-DOM-components-with-class highlighted-text, \highlight).length, 2

    specify "must apply styles to the root node", ->
        highlighted-text = create-highlighted-text do 
            style: display: \inline-block
        assert.equal (find-DOM-node highlighted-text).style.display, \inline-block

    specify "must apply props.highlightStyle when highlight is true", ->
        highlighted-text = create-highlighted-text do 
            highlight-style: font-weight: \bold
        assert.equal (find-DOM-node (scry-rendered-DOM-components-with-class highlighted-text, \highlight).0).style.font-weight, \bold