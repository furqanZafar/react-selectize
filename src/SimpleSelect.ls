{all, any, drop, camelize, difference, filter, find, find-index, last, map, reject} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
{create-factory, DOM:{div, img, span}}:React = require \react
ReactSelectize = create-factory require \./ReactSelectize

module.exports = React.create-class do

    display-name: \SimpleSelect

    # get-default-props :: a -> Props
    get-default-props: ->
        # class-name :: String
        # disabled :: Boolean
        delimiters: []
        # create-from-search :: [Item] -> String -> Item?
        # editable :: Item -> String
        # filter-options :: [Item] -> String -> [Item]
        filter-options: (options, search) -->  
            options
                |> filter ~> (it.label.to-lower-case!.trim!.index-of search.to-lower-case!.trim!) > -1
        on-blur: ((value, reason) !->) # :: Item -> String -> Void
        on-enter: ((highlighted-option) !->) # :: Item -> Void
        on-focus: ((value, reason) !->) # :: Item -> String -> Void
        # on-search-change :: String -> (a -> Void) -> Void
        # on-value-change :: Item -> (a -> Void) -> Void 
        # options :: [Item]
        placeholder: ""
        # render-no-results-found :: Item -> String -> ReactElement
        # render-option :: Int -> Item -> ReactElement
        # render-value :: Int -> Item -> ReactElement
        # restore-on-backspace :: Item -> String
        # search :: String
        style: {}
        tether: false
        # uid :: (Equatable e) => Item -> e
        # value :: Item

    # render :: a -> ReactElement
    render: -> 
        
        {search, value, values, on-search-change, on-value-change, filtered-options, options} = @get-computed-state!

        # props
        {autosize, delimiters, disabled, dropdown-direction, group-id, groups, groups-as-columns, on-enter, render-group-title, 
        tether, transition-enter, transition-leave, transition-enter-timeout, transition-leave-timeout, uid} = @props
        
        ReactSelectize {
            
            autosize
            class-name: "simple-select" + if !!@props.class-name then " #{@props.class-name}" else ""
            delimiters
            disabled
            dropdown-direction
            group-id
            groups
            groups-as-columns
            on-enter
            render-group-title
            tether
            transition-enter
            transition-enter-timeout
            transition-leave
            transition-leave-timeout
            uid

            ref: \select

            # ANCHOR
            anchor: last values
            on-anchor-change: (, callback) ~> callback!

            # OPEN
            open: @state.open
            on-open-change: (open, callback = (->)) ~>
                <~ do ~> (callback) ~> if !!open then @show-options callback else @set-state {open}, callback
                if !!@props.editable and (!!@state.open and !!value)
                    <~ on-search-change @props.editable value
                    @highlight-first-selectable-option callback
                else 
                    callback!

            highlighted-uid: @state.highlighted-uid
            on-highlighted-uid-change: (highlighted-uid, callback) ~> @set-state {highlighted-uid}, callback

            # OPTIONS            
            first-option-index-to-highlight: ~> @first-option-index-to-highlight options, value
                
            options: options
            render-option: @props.render-option
            render-no-results-found: @props.render-no-results-found

            # SEARCH
            search: search
            on-search-change: (search, callback) ~> on-search-change search, callback

            # VALUES
            values: values
            on-values-change: (new-values, callback) ~>
                if new-values.length == 0
                    <~ on-value-change undefined
                    @focus callback
                else
                    new-value = last new-values
                    changed = !(new-value `is-equal-to-object` value)
                    <~ do ~> (callback) ~> if changed then on-value-change new-value, callback else callback!
                    <~ @set-state open: false
                    @refs.select.blur!
                    callback!
            render-value: @props.render-value

            # on blur clear out the search text
            on-blur: (, reason) !~> 
                <~ do ~> (callback) ~> if search.length > 0 then on-search-change "", callback else callback!
                @props.on-blur value, reason

            on-focus: (, reason) !~> @props.on-focus value, reason

            # STYLE
            placeholder: @props.placeholder
            style: @props.style

        } 
        <<< (switch
        | typeof @props.restore-on-backspace == \function => restore-on-backspace: @props.restore-on-backspace
        | _ => {})
        <<< (switch
        | typeof @props.render-no-results-found == \function => 
            render-no-results-found: ~> @props.render-no-results-found value, search
        | _ => {})

    # get-computed-state :: a -> UIState
    get-computed-state: ->

        # decide whether to use state or props
        search = if @props.has-own-property \search then @props.search else @state.search
        value = if @props.has-own-property \value then @props.value else @state.value  
        show-value = if !!@props.editable then !@state.open else search.length == 0
        values = if !!value and show-value then [value] else []
        [on-search-change, on-value-change] = <[search value]> |> map (p) ~>
            | @props.has-own-property p and @props.has-own-property camelize "on-#{p}-change" => 
                @props[camelize "on-#{p}-change"]

            | @props.has-own-property p and !(@props.has-own-property camelize "on-#{p}-change") => 
                (, callback) ~> callback!

            | !(@props.has-own-property p) and @props.has-own-property camelize "on-#{p}-change" => 
                (o, callback) ~> 
                    <~ @set-state {"#{p}" : o}
                    @props[camelize "on-#{p}-change"] o, callback

            | !(@props.has-own-property p) and !(@props.has-own-property camelize "on-#{p}-change") => 
                (o, callback) ~> @set-state {"#{p}" : o}, callback

        # get options from props.children
        options-from-children = switch
            | !!@props?.children => 
                (if typeof! @props.children == \Array then @props.children else [@props.children]) |> map -> 
                    {value, children}? = it?.props
                    label: children, value: value
            | _ => []

        # props.options is preferred over props.children
        unfiltered-options = if @props.has-own-property \options then (@props.options ? []) else options-from-children

        # filter options and create new one from search text
        filtered-options = @props.filter-options unfiltered-options, search
        new-option = 
            | typeof @props.create-from-search == \function => @props.create-from-search filtered-options, search
            | _ => null
        options = (if !!new-option then [{} <<< new-option <<< new-option: true] else []) ++ filtered-options

        {search, value, values, on-search-change, on-value-change, filtered-options, options}

    # get-initial-state :: a -> UIState
    get-initial-state: ->
        highlighted-uid: undefined
        open: false
        search: ""
        value: @props?.default-value

    # first-option-index-to-highlight :: [Item] -> Item -> Int
    first-option-index-to-highlight: (options, value) ->
        index = if !!value then (find-index (~> it `is-equal-to-object` value), options) else undefined
        switch
            | typeof index != \undefined => index
            | options.length == 1 => 0
            | (typeof options.0?.new-option) == \undefined => 0
            | _ =>    
                if (options
                    |> drop 1
                    |> all -> (typeof it.selectable == \boolean) and !it.selectable)
                    0
                else
                    1

    # fires the on-focus event after moving the cursor to the search input (with the reason = function-call)
    # fires the callback after the dropdown becomes visible
    # focus :: (a -> Void) -> Void
    focus: (callback) !-> 
        @refs.select.focus-on-input!
        @show-options callback

    # fires the on-blur event after closing the dropdown (with the reason = function-call)
    # blur :: () -> Void
    blur: !-> @refs.select.blur!

    # highlight-the-first-selectable-option :: (a -> Void) -> Void
    highlight-first-selectable-option: (callback = (->)) !->
        return callback! if !@state.open
        {options, value} = @get-computed-state!
        @refs.select.highlight-and-scroll-to-selectable-option do 
            @first-option-index-to-highlight options, value
            1
            callback

    # show-options :: (a -> Void) -> Void
    show-options: (callback) !->
        @set-state do 
            open: 
                | @props.disabled => false 
                | _ => true
            callback

    # value :: a -> Item
    value: -> if @props.has-own-property \value then @props.value else @state.value