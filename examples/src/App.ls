$ = require \jquery-browserify
{any, concat-map, filter, find, fold, map, reject, unique-by} = require \prelude-ls
{create-factory, DOM:{a, div, h1, h2, img, span}}:React = require \react
MultiSelect = create-factory require \./MultiSelect.ls
SimpleSelect = create-factory require \SimpleSelect.ls

App = React.create-class do

    render: -> 
        div null,
            div do 
                class-name: \title
                'React Selectize'
            div {class-name: \description}, 'A flexible and beautiful Multi Select input control for ReactJS'
            a {class-name: \github-link, href: 'http://github.com/furqanZafar/react-select/tree/develop', target: \_blank}, 'View project on GitHub'
            h1 null, 'Examples:'

            SimpleSelect do 
                create-from-search: (options, search) -> 
                    if search.length == 0 or search in map (.label), options then null else label: search, value: search
                restore-on-backspace: -> it.label.substr 0, it.label.length - 1
                options: [0 til 100] |> map ~> {label: "#{it} fruit#{if it == 0 then '' else 's'}", value: it}
                ref: \select

            MultiSelect do 
                create-from-search: (options, values, search) -> 
                    if search.length == 0 or search in map (.label), values ++ options then null else label: search, value: search
                options: @state.options
                filter-options: (options, values, search) ~>
                    options 
                        |> filter -> (it.label.to-lower-case!.trim!.index-of search.to-lower-case!.trim!) > -1
                on-values-change: (values, callback) ~>
                    @set-state do 
                        options: values 
                            |> reject ~> it.value in map (.value), @state.options
                            |> map ~> delete it.new-option; it
                            |> fold do 
                                (memo, v) ~> [v] ++ memo
                                @state.options
                            |> map ({value}:option) ~> 
                                {} <<< option <<< selectable: !(value in (map (.value), values))
                        callback
                style: margin-top: 50
                max-values: @state.options.length

            div {class-name: \copy-right}, 'Copyright © Furqan Zafar 2015. MIT Licensed.'

    get-initial-state: -> value: undefined, options: <[test cap tail coat teseract tesla]> |> map -> label: it, value: it

React.render (React.create-element App, null), document.body