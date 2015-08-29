{all, any, camelize, difference, drop, filter, find, find-index, last, map, reject} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
{create-factory, DOM:{div, img, span}}:React = require \react
ReactSelectize = create-factory require \ReactSelectize.ls

module.exports = React.create-class do

    # get-default-props :: a -> Props
    get-default-props: ->
        # class-name :: String
        close-on-select: false
        # disabled :: Boolean
        # create-from-search :: [Item] -> [Item] -> String -> Item?
        # filter-options :: [Item] -> [Item] -> String -> [Item]
        filter-options: (options, values, search) -->  
            options
                |> reject ~> it.label.to-lower-case!.trim! in (map (.label.to-lower-case!.trim!), values ? [])
                |> filter ~> (it.label.to-lower-case!.trim!.index-of search.to-lower-case!.trim!) > -1
                |> -> it ? []
        # max-values :: Int
        on-blur: ((value, reason) !->) # :: Item -> String -> Void
        on-focus: ((value, reason) !->) # :: Item -> String -> Void
        # on-search-change :: String -> (a -> Void) -> Void
        # on-value-change :: Item -> (a -> Void) -> Void 
        options: []
        # placeholder :: String
        # render-no-results-found :: a -> ReactElement
        # render-option :: Int -> Item -> ReactElement
        # render-value :: Int -> Item -> ReactElement
        # restore-on-backspace :: Item -> String
        # search :: String
        # style :: CSS
        # values :: [Item]

    # render :: a -> ReactElement
    render: -> 
        
        # decide whether to use state or props
        search = if @props.has-own-property \search then @props.search else @state.search
        values = @values!
        [on-search-change, on-values-change] = <[search values]> |> map (p) ~>
            | @props.has-own-property p and @props.has-own-property camelize "on-#{p}-change" => @props[camelize "on-#{p}-change"]
            | @props.has-own-property p and !(@props.has-own-property camelize "on-#{p}-change") => (, callback) ~> callback!
            | !(@props.has-own-property p) and @props.has-own-property camelize "on-#{p}-change" => 
                (o, callback) ~> 
                    <~ @set-state {"#{p}" : o}
                    @props[camelize "on-#{p}-change"] o, callback
            | !(@props.has-own-property p) and !(@props.has-own-property camelize "on-#{p}-change") => 
                (o, callback) ~> @set-state {"#{p}" : o}, callback

        # filter options and create new one from search text
        filtered-options = @props.filter-options @props.options, values, search
        new-option = if typeof @props.create-from-search == \function then (@props.create-from-search filtered-options, values, search) else null
        options = (if !!new-option then [{} <<< new-option <<< new-option: true] else []) ++ filtered-options

        ReactSelectize {
            
            class-name: "multi-select #{@props.class-name}"
            disabled: @props.disabled
            ref: \select

            # ANCHOR
            anchor: @state.anchor
            on-anchor-change: (anchor, callback) ~> @set-state {anchor}, callback

            # OPEN
            open: @state.open
            on-open-change: (open, callback) ~> if open then @show-options callback else @set-state {open}, callback

            # OPTIONS            
            first-option-index-to-highlight: (options) ~> 
                switch
                    | options.length == 1 => 0
                    | typeof options?.0?.new-option == \undefined => 0
                    | _ =>    
                        if (options
                            |> drop 1
                            |> all -> (typeof it.selectable == \boolean) and !it.selectable)
                            0
                        else
                            1
            options: options
            render-option: @props.render-option
            render-no-results-found: @props.render-no-results-found

            # SEARCH
            search: search
            on-search-change: (search, callback) ~> on-search-change (if !!@props.max-values and values.length >= @props.max-values then "" else search), callback
                
            # VALUES
            values: values
            on-values-change: (new-values, callback) ~>
                <~ on-values-change new-values
                @refs.select.focus!
                if @props.close-on-select or (!!@props.max-values and new-values.length >= @props.max-values) 
                    @set-state {open: false}, callback 
                else 
                    callback!
            render-value: @props.render-value

            # STYLE
            on-blur: (, reason) !~> 
                <~ @set-state {anchor: last values}
                @props.on-blur values, reason
            on-focus: (, reason) !~> @props.on-focus values, reason
            placeholder: @props.placeholder
            style: @props.style

        } <<< switch
        | typeof @props.restore-on-backspace == \function => restore-on-backspace: @props.restore-on-backspace
        | _ => {}


    # get-initial-state :: a -> UIState
    get-initial-state: ->
        anchor: undefined
        open: false
        search: ""
        values: []

    # focus :: a -> Void
    focus: !-> 
        @refs.select.focus!
        @show-options

    # show-options :: (a -> Void)? -> Void
    show-options: (callback = (->)) !->
        @set-state do 
            open: 
                | @props.disabled => false 
                | typeof @props.max-values != \undefined and @values!.length >= @props.max-values => false 
                | _ => true
            callback

    # value :: a -> Item
    values: -> if @props.has-own-property \values then @props.values else @state.values