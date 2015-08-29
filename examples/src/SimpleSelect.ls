{all, any, drop, camelize, difference, filter, find, find-index, last, map, reject} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
{create-factory, DOM:{div, img, span}}:React = require \react
ReactSelectize = create-factory require \ReactSelectize.ls

module.exports = React.create-class do

    # get-default-props :: a -> Props
    get-default-props: ->
        # class-name :: String
        # disabled :: Boolean
        # create-from-search :: [Item] -> String -> Item?
        # filter-options :: [Item] -> Item -> String -> [Item]
        filter-options: (options, value, search) -->  
            options
                |> filter ~> (it.label.to-lower-case!.trim!.index-of search.to-lower-case!.trim!) > -1
                |> -> it ? []
        on-blur: ((value, reason) !->) # :: Item -> String -> Void
        on-focus: ((value, reason) !->) # :: Item -> String -> Void
        # on-search-change :: String -> (a -> Void) -> Void
        # on-value-change :: Item -> (a -> Void) -> Void 
        options: []
        placeholder: ""
        # render-no-results-found :: a -> ReactElement
        # render-option :: Int -> Item -> ReactElement
        # render-value :: Int -> Item -> ReactElement
        # restore-on-backspace :: Item -> String
        # search :: String
        style: {}
        # value :: Item

    # render :: a -> ReactElement
    render: -> 
        
        # decide whether to use state or props
        search = if @props.has-own-property \search then @props.search else @state.search
        value = if @props.has-own-property \value then @props.value else @state.value
        values = if !!value then [value] else []
        [on-search-change, on-value-change] = <[search value]> |> map (p) ~>
            | @props.has-own-property p and @props.has-own-property camelize "on-#{p}-change" => @props[camelize "on-#{p}-change"]
            | @props.has-own-property p and !(@props.has-own-property camelize "on-#{p}-change") => (, callback) ~> callback!
            | !(@props.has-own-property p) and @props.has-own-property camelize "on-#{p}-change" => 
                (o, callback) ~> 
                    <~ @set-state {"#{p}" : o}
                    @props[camelize "on-#{p}-change"] o, (->)
                    callback!
            | !(@props.has-own-property p) and !(@props.has-own-property camelize "on-#{p}-change") => 
                (o, callback) ~> @set-state {"#{p}" : o}, callback

        # filter options and create new one from search text
        filtered-options = @props.filter-options @props.options, value, search
        new-option = if typeof @props.create-from-search == \function then (@props.create-from-search filtered-options, search) else null
        options = (if !!new-option then [{} <<< new-option <<< new-option: true] else []) ++ filtered-options

        ReactSelectize {
            
            class-name: "simple-select #{@props.class-name}"
            disabled: @props.disabled
            ref: \select

            # ANCHOR
            anchor: last values
            on-anchor-change: (, callback) ~> callback!

            # OPEN
            open: @state.open
            on-open-change: (open, callback) ~> if !!open then @show-options callback else @set-state {open}, callback

            # OPTIONS            
            first-option-index-to-highlight: (options) ~> 
                index = if !!value then (find-index (~> it `is-equal-to-object` value), options) else undefined
                switch
                    | typeof index != \undefined => index
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
            on-search-change: (search, callback) ~> 
                <~ do ~> (callback) ~> if search.length > 0 and !!value then on-value-change undefined, callback else callback!
                on-search-change search, callback

            # VALUES
            values: values
            on-values-change: (new-values, callback) ~>
                if new-values.length == 0
                    <~ on-value-change undefined
                    <~ @show-options
                    @refs.select.focus!
                    callback!
                else
                    [value] = new-values `difference` values
                    <~ do ~> (callback) ~> if !!value then on-value-change value, callback else callback!
                    <~ @set-state open: false
                    @refs.select.blur!
                    callback!
            render-value: @props.render-value

            # STYLE
            on-blur: (, reason) !~> @props.on-blur value, reason
            on-focus: (, reason) !~> @props.on-focus value, reason
            placeholder: @props.placeholder
            style: @props.style

        } <<< switch
        | typeof @props.restore-on-backspace == \function => restore-on-backspace: @props.restore-on-backspace
        | _ => {}


    # get-initial-state :: a -> UIState
    get-initial-state: ->
        open: false
        search: ""
        value: undefined

    # focus :: a -> Void
    focus: !-> 
        @refs.select.focus!
        <~ @show-options

    # show-options :: (a -> Void) -> Void
    show-options: (callback) !->
        @set-state do 
            open: 
                | @props.disabled => false 
                | _ => true
            callback

    # value :: a -> Item
    value: -> if @props.has-own-property \value then @props.value else @state.value