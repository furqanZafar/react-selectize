{all, any, camelize, difference, drop, filter, find, find-index, last, map, reject} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
{create-factory, DOM:{div, img, span}}:React = require \react
ReactSelectize = create-factory require \./ReactSelectize 

module.exports = React.create-class do

    display-name: \MultiSelect

    # get-default-props :: a -> Props
    get-default-props: ->
        # anchor :: Item
        # class-name :: String
        close-on-select: false
        # disabled :: Boolean
        # create-from-search :: [Item] -> [Item] -> String -> Item?
        # filter-options :: [Item] -> [Item] -> String -> [Item]
        filter-options: (options, values, search) -->   
            options
                |> reject ~> it.label.to-lower-case!.trim! in (map (.label.to-lower-case!.trim!), values ? [])
                |> filter ~> (it.label.to-lower-case!.trim!.index-of search.to-lower-case!.trim!) > -1
        # max-values :: Int
        # on-anchor-change :: Item -> (a -> Void) -> Void
        on-blur: ((values, reason) !->) # :: [Item] -> String -> Void
        on-focus: ((values, reason) !->) # :: [Item] -> String -> Void
        # on-search-change :: String -> (a -> Void) -> Void
        # on-value-change :: Item -> (a -> Void) -> Void 
        # options :: [Item]
        # placeholder :: String
        # render-no-results-found :: [Item] -> String -> ReactElement
        # render-option :: Int -> Item -> ReactElement
        # render-value :: Int -> Item -> ReactElement
        # restore-on-backspace :: Item -> String
        # search :: String
        # style :: CSS
        # values :: [Item]

    # render :: a -> ReactElement
    render: -> 
        
        {anchor, search, values, on-anchor-change, on-search-change, on-values-change, filtered-options, options} = @get-computed-state!
        {autosize, disabled, dropdown-direction, group-id, groups, groups-as-columns, render-group-title, uid} = @props

        ReactSelectize {
            
            autosize
            class-name: "multi-select" + if !!@props.class-name then " #{@props.class-name}" else ""
            disabled
            dropdown-direction
            group-id
            groups
            groups-as-columns
            render-group-title
            uid
            ref: \select

            # ANCHOR
            anchor: anchor
            on-anchor-change: on-anchor-change

            # OPEN
            open: @state.open
            on-open-change: (open, callback) ~> if open then @show-options callback else @set-state {open}, callback

            highlighted-uid: @state.highlighted-uid
            on-highlighted-uid-change: (highlighted-uid, callback) ~> @set-state {highlighted-uid}, callback

            # OPTIONS            
            first-option-index-to-highlight: ~> @first-option-index-to-highlight options
                
            options: options
            render-option: @props.render-option

            # SEARCH
            search: search
            on-search-change: (search, callback) ~> 
                on-search-change (if !!@props.max-values and values.length >= @props.max-values then "" else search), callback
                
            # VALUES
            values: values
            on-values-change: (new-values, callback) ~>
                <~ on-values-change new-values
                if @props.close-on-select or (!!@props.max-values and new-values.length >= @props.max-values) 
                    @set-state {open: false}, callback 
                else 
                    @focus callback
            render-value: @props.render-value

            # on blur move the anchor to the end, and reset the search text
            on-blur: (, reason) !~> 
                <~ @set-state {anchor: last values}
                <~ on-search-change ""
                @props.on-blur values, reason
            
            on-focus: (, reason) !~> @props.on-focus values, reason

            # STYLE
            placeholder: @props.placeholder
            style: @props.style

        } 
        <<< switch
        | typeof @props.restore-on-backspace == \function => restore-on-backspace: @props.restore-on-backspace
        | _ => {}
        <<< switch
        | typeof @props.render-no-results-found == \function => render-no-results-found: ~> @props.render-no-results-found values, search
        | _ => {}


    # get-computed-state :: a -> UIState
    get-computed-state: ->

        # decide whether to use state or props
        anchor = if @props.has-own-property \anchor then @props.anchor else @state.anchor
        search = if @props.has-own-property \search then @props.search else @state.search
        values = @values!
        [on-anchor-change, on-search-change, on-values-change] = <[anchor search values]> |> map (p) ~>
            | @props.has-own-property p and @props.has-own-property camelize "on-#{p}-change" => @props[camelize "on-#{p}-change"]
            | @props.has-own-property p and !(@props.has-own-property camelize "on-#{p}-change") => (, callback) ~> callback!
            | !(@props.has-own-property p) and @props.has-own-property camelize "on-#{p}-change" => 
                (o, callback) ~> 
                    <~ @set-state {"#{p}" : o}
                    @props[camelize "on-#{p}-change"] o, callback
            | !(@props.has-own-property p) and !(@props.has-own-property camelize "on-#{p}-change") => 
                (o, callback) ~> @set-state {"#{p}" : o}, callback

        # get options from props.children
        options-from-children = switch
            | !!@props?.children => 
                (if typeof! @props.children == \Array then @props.children else [@props.children]) |> map ({props}?) -> 
                    {value, children}? = props
                    label: children, value: value
            | _ => []

        # props.options is preferred over props.children
        unfiltered-options = if @props.has-own-property \options then (@props.options ? []) else options-from-children

        # filter options and create new one from search text
        filtered-options = @props.filter-options unfiltered-options, values, search
        new-option = if typeof @props.create-from-search == \function then (@props.create-from-search filtered-options, values, search) else null
        options = (if !!new-option then [{} <<< new-option <<< new-option: true] else []) ++ filtered-options

        {anchor, search, values, on-anchor-change, on-search-change, on-values-change, filtered-options, options}
        
    # get-initial-state :: a -> UIState
    get-initial-state: ->
        anchor: if !!@props.values then last @props.values else undefined
        highlighted-uid: undefined
        open: false
        search: ""
        values: []

    # first-option-index-to-highlight :: [Item] -> Int
    first-option-index-to-highlight: (options) ->
        switch
            | options.length == 1 => 0
            | typeof options.0?.new-option == \undefined => 0
            | _ =>    
                if (options
                    |> drop 1
                    |> all -> (typeof it.selectable == \boolean) and !it.selectable)
                    0
                else
                    1

    # focus :: a -> (a -> Void) -> Void
    focus: (callback) -> 
        @refs.select.focus!
        @show-options callback

    # highlight-the-first-selectable-option :: a -> Void
    highlight-first-selectable-option: !->
        return if !@state.open
        {options} = @get-computed-state!
        @refs.select.highlight-and-scroll-to-selectable-option (@first-option-index-to-highlight options), 1

    # show-options :: (a -> Void)? -> Void
    show-options: (callback) !->
        @set-state do 
            open: 
                | @props.disabled => false 
                | typeof @props.max-values != \undefined and @values!.length >= @props.max-values => false 
                | _ => true
            callback

    # value :: a -> Item
    values: -> if @props.has-own-property \values then @props.values else @state.values