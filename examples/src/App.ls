$ = require \jquery-browserify
{any, concat-map, filter, find, map, reject, unique-by} = require \prelude-ls
{create-factory, DOM:{a, div, h1, h2, img, span}}:React = require \react
ReactSelectize = create-factory require \../../src/ReactSelectize.ls

App = React.create-class do

    render: -> 
        div null,
            div {class-name: \title}, 'React Selectize'
            div {class-name: \description}, 'A flexible and beautiful Multi Select input control for ReactJS'
            a {class-name: \github-link, href: 'http://github.com/furqanZafar/react-select/tree/develop', target: \_blank}, 'View project on GitHub'
            h1 null, 'Examples:'

            #TAGGING
            ReactSelectize do 
                open: @state.show-tags
                on-open-change: (open, callback) ~> @set-state {show-tags: open}, callback
                options: @state.tags 
                    |> reject ~> it.label.to-lower-case!.trim! in (map (.label.to-lower-case!.trim!), @state.selected-tags)
                    |> filter ~> (it.label.to-lower-case!.trim!.index-of @state.tags-search.to-lower-case!.trim!) > -1                    
                    |> (options) ~> 
                        {tags-search, selected-tags} = @state
                        return options if options.length > 0
                        return [] if tags-search.length == 0
                        return [] if !!(find (.label.to-lower-case!.trim! == tags-search.to-lower-case!.trim!), selected-tags)
                        [{label: tags-search, value: tags-search, new-option: true}]
                render-option: (index, {label, new-option}?) ~>
                    div do 
                        class-name: "simple-option"
                        key: index
                        if !!new-option then "Add #label ..." else label
                render-no-results-found: ~>
                    div do 
                        class-name: \no-results-found
                        if @state.tags-search.length == 0 then "type to create a new tag" else "tag already exits"
                search: @state.tags-search
                on-search-change: (search, callback) ~> @set-state {tags-search:search}, callback
                values: @state.selected-tags
                on-values-change: (selected-tags, callback) ~> @set-state {selected-tags}, callback
                render-value: (index, {label}) ~>
                    div do 
                        class-name: \simple-value
                        key: index
                        span null, label
                placeholder: 'Select tags'
                style: z-index: 2

            # EMOJIS
            ReactSelectize do 
                open: @state.selected-emojis.length < 3 and @state.show-emojis
                on-open-change: (open, callback) ~> @set-state {show-emojis: open}, callback
                options: @state.emojis
                    |> reject ~> @state.selected-emojis.length >= 3 
                    |> reject ~> it.description.to-lower-case!.trim! in (map (.description.to-lower-case!.trim!), @state.selected-emojis)
                    |> filter ~> 
                        ((it.description.to-lower-case!.trim!.index-of @state.emojis-search.to-lower-case!.trim!) > -1) or 
                        (it.tags |> any (tag) ~> (tag.to-lower-case!.trim!.index-of @state.emojis-search.to-lower-case!.trim!) > -1)
                render-option: (index, {emoji, description, selectable}?) ~>
                    is-selectable = (typeof selectable == \undefined) or selectable
                    div do 
                        class-name: "emoji-option"
                        key: index
                        style: cursor: if is-selectable then \pointer else \default
                        if is-selectable
                            img src: "http://localhost:4020/images/emojis/#{emoji}.png"
                        span null, description
                render-no-results-found: ~>
                    div do 
                        class-name: \no-results-found
                        switch 
                        | @state.selected-emojis.length >= 3 => "emojis selected"
                        | @state.emojis-search.length > 0 => "no emojis found"
                        | _ => "" 
                search: @state.emojis-search
                on-search-change: (search, callback) ~> if @state.selected-emojis.length >= 3 then callback! else @set-state {emojis-search:search}, callback
                values: @state.selected-emojis
                on-values-change: (selected-emojis, callback) ~> @set-state {selected-emojis}, callback
                render-value: (index, {emoji, description}) ~>
                    div do 
                        class-name: \emoji-value
                        key: index
                        span do
                            on-click: (e) ~> 
                                @set-state do 
                                    selected-emojis: [0 til @state.selected-emojis.length]
                                        |> reject (== index)
                                        |> map ~> @state.selected-emojis[it]
                                e.prevent-default!
                                e.stop-propagation!
                            \x
                        img src: "http://localhost:4020/images/emojis/#{emoji}.png"
                restore-on-backspace: (.description)
                placeholder: 'Select three emojis'
                style: 
                    margin-top: 60
                    z-index: 1
                
            div {class-name: \copy-right}, 'Copyright © Furqan Zafar 2015. MIT Licensed.'

    get-initial-state: ->

        # TAGS
        tags-search: ""
        tags: []
        selected-tags: []
        show-tags: false

        # EMOJIS
        emojis-search: ""
        emojis: []
        selected-emojis: []
        show-emojis: false

        # COUNTRIES
        countries-search: ""
        countries: []
        selected-countries: []

        # CITIES
        cities-search: ""
        cities: []
        selected-cities: []

    component-will-mount: ->
        $.getJSON \http://localhost:4020/emojis?sortKey=description&sortOrder=1&limit=200
            ..done (emojis) ~> @set-state {emojis}


React.render do
    React.create-element do 
        App
        countries: [{value: \ae, label: \UAE}, {value: \us, label: \USA}]
    document.body