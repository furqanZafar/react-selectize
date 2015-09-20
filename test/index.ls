require! \assert
require! \jsdom
global <<< 
    document: jsdom.jsdom '<!doctype html><html><body></body></html>'
    navigator: user-agent: \JSDOM
    window: document.parent-window
{map} = require \prelude-ls
{addons:{TestUtils}, create-class, create-element, DOM:{div}} = require \react/addons
{ReactSelectize, SimpleSelect, MultiSelect} = require \../src/index.ls

describe "", ->
    specify "", ->
        select = TestUtils.render-into-document create-element do 
            SimpleSelect
            options: <[apple mango orange]> |> map ~> label: it, value: it