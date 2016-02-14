{all, any, camelize, difference, drop, filter, find, find-index, last, map, reject} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
{create-factory, DOM:{div, img, span}}:React = require \react
ReactSelectize = create-factory require \./ReactSelectize 
{cancel-event} = require \./utils

module.exports = React.create-class do

    display-name: \MultiSelect

    # get-default-props :: () -> Props
    get-default-props: ->
        # autofocus :: Boolean
        # anchor :: Item
        class-name: ""
        close-on-select: false
        # values-from-paste :: String -> [Item]
        default-values: []
        delimiters: []
        # disabled :: Boolean
        # create-from-search :: [Item] -> [Item] -> String -> Item?
        # filter-options :: [Item] -> [Item] -> String -> [Item]
        filter-options: (options, values, search) -->   
            options
                |> reject ~> it.label.trim! in (map (.label.trim!), values ? [])
                |> filter ~> (it.label.to-lower-case!.trim!.index-of search.to-lower-case!.trim!) > -1
        # hide-reset-button :: Boolean
        # input-props :: object
        # max-values :: Int
        # on-anchor-change :: Item -> ()
        on-blur: ((e) !->) # :: # Event -> ()
        on-focus: ((e) !->) # :: Event -> ()
        # on-keyboard-selection-failed :: Int -> ()
        on-paste: ((e) !-> true) # Event -> Boolean
        # on-search-change :: String -> ()
        # on-value-change :: Item -> () 
        # options :: [Item]
        # placeholder :: String
        # render-toggle-button :: ({open :: Boolean, flipped :: Boolean}) -> ReactElement
        # render-no-results-found :: [Item] -> String -> ReactElement
        # render-option :: Int -> Item -> ReactElement
        # render-reset-button :: () -> ReactElement
        # render-value :: Int -> Item -> ReactElement
        # restore-on-backspace :: Item -> String
        # search :: String
        serialize: map (?.value) # [Item] -> String
        # style :: CSS
        tether: false
        # theme :: String
        # values :: [Item]

    # render :: () -> ReactElement
    render: -> 
        
        # computed state
        {
            anchor, filtered-options, on-anchor-change, on-open-change, on-search-change, on-values-change, search, open
            options, values
        } = @get-computed-state!

        # props
        {
            autofocus, autosize, delimiters, disabled, dropdown-direction, group-id, groups, groups-as-columns, hide-reset-button, 
            input-props, name, on-keyboard-selection-failed, render-toggle-button, render-group-title, render-reset-button, 
            serialize, tether, theme, transition-enter, transition-leave, transition-enter-timeout, transition-leave-timeout, uid
        }? = @props

        ReactSelectize {
            
            autofocus
            autosize
            class-name: "multi-select #{@props.class-name}"
            delimiters
            disabled
            dropdown-direction
            group-id
            groups
            groups-as-columns
            hide-reset-button
            input-props
            name
            on-keyboard-selection-failed
            render-group-title
            render-reset-button
            render-toggle-button
            scroll-lock: @state.scroll-lock
            on-scroll-lock-change: (scroll-lock) ~> @set-state {scroll-lock}
            tether
            theme
            transition-enter
            transition-enter-timeout
            transition-leave
            transition-leave-timeout
            uid
            ref: \select

            # ANCHOR
            anchor
            on-anchor-change

            # OPEN
            open
            on-open-change

            # HIGHLIGHTED OPTION
            highlighted-uid: @state.highlighted-uid
            on-highlighted-uid-change: (highlighted-uid, callback) ~> 
                @set-state {highlighted-uid}, callback

            # OPTIONS            
            options: options
            render-option: @props.render-option
            first-option-index-to-highlight: ~> @first-option-index-to-highlight options

            # SEARCH
            search: search
            on-search-change: (search, callback) ~> 

                # block search, if we have reached the limit (if any)
                on-search-change do
                    if !!@props.max-values and values.length >= @props.max-values then "" else search
                    callback
                
            # VALUES
            values: values
            on-values-change: (new-values, callback) ~>
                <~ on-values-change new-values
                callback!

                # close dropdown (if we reached the limit - if any -, or props.close-on-select is set)
                if @props.close-on-select or (!!@props.max-values and @values!.length >= @props.max-values) 
                    <~ on-open-change false
            render-value: @props.render-value

            # FORM SERIALIZATION
            serialize: serialize

            # BLUR & FOCUS
            on-blur: (e) !~> 
                <~ on-search-change ""
                @props.on-blur {open, values, original-event: e}
            on-focus: (e) !~> @props.on-focus {open, values, original-event: e}

            # on-paste :: Event -> Boolean
            on-paste: 
                | typeof @props?.values-from-paste == \undefined => @props.on-paste
                | _ => ({clipboard-data}:e) ~>
                    do ~>

                        # new-values is a concatenation of existing values with the values returned by a user defined function
                        # that converts the pasted text into an array of values
                        new-values = values ++ (@props.values-from-paste options, values, clipboard-data.get-data \text)

                        # update the state with new-values
                        <~ on-values-change new-values 

                        # move the anchor to the end
                        on-anchor-change last new-values

                    cancel-event e

            # STYLE
            placeholder: @props.placeholder
            style: @props.style

        } 

        <<< (switch
        | typeof @props.restore-on-backspace == \function => restore-on-backspace: @props.restore-on-backspace
        | _ => {})

        <<< (switch
        | typeof @props.render-no-results-found == \function => 
            render-no-results-found: ~> @props.render-no-results-found values, search
        | _ => {})


    # get-computed-state :: () -> UIState
    get-computed-state: ->

        # decide whether to use state or props
        anchor = if @props.has-own-property \anchor then @props.anchor else @state.anchor
        open = @is-open!
        search = if @props.has-own-property \search then @props.search else @state.search
        values = @values!
        [on-anchor-change, on-open-change, on-search-change, on-values-change] = <[anchor open search values]> |> map (p) ~>

            # both p & its change callback are coming from props (simply returns the change callback from props)
            | @props.has-own-property p and @props.has-own-property camelize "on-#{p}-change" => 
                (o, callback) ~> 
                    @props[camelize "on-#{p}-change"] o, (->)

                    # trick react into running batch update, this indirectly updates the props
                    @set-state {}, callback

            # p is coming from prop but the change callback is coming from state 
            # (do nothing, just invoke the callback - p remains unchanged -)
            | @props.has-own-property p and !(@props.has-own-property camelize "on-#{p}-change") => 
                (, callback) ~> callback!

            # p is coming from state but the change callback is coming from props
            # update the value of p in state and invoke the change callback (present in props)
            | !(@props.has-own-property p) and @props.has-own-property camelize "on-#{p}-change" => 
                (o, callback) ~> 
                    <~ @set-state "#{p}" : o
                    callback!
                    
                    @props[camelize "on-#{p}-change"] o, (->)

            # both p and its change callback are coming from state
            # update the state & on success invoke the change callback
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
        new-option = 
            | typeof @props.create-from-search == \function => @props.create-from-search filtered-options, values, search
            | _ => null

        # the final list of options is the concatination of any new-option, created from search, or [] with 
        # the list of filtered options
        options = (if !!new-option then [{} <<< new-option <<< new-option: true] else []) ++ filtered-options

        {
            anchor
            search
            values
            on-anchor-change
            open
            
            # on-open-change :: Boolean -> (() -> ()) -> ()
            on-open-change: (open, callback) !~>
                on-open-change do 
                    switch
                    | typeof @props.max-values != \undefined and @values!.length >= @props.max-values => false
                    | _ => open
                    callback
                    
            on-search-change
            on-values-change
            filtered-options
            options
        }
        
    # get-initial-state :: () -> UIState
    get-initial-state: ->
        anchor: if !!@props.values then last @props.values else undefined
        highlighted-uid: undefined
        open: false
        scroll-lock: false
        search: ""
        values: @props.default-values

    # first-option-index-to-highlight :: [Item] -> Int
    first-option-index-to-highlight: (options) ->
        switch

            # highlight the first option if there is only one option
            | options.length == 1 => 0

            # highlight the first option if isn't coming from (create-from-search prop)
            | typeof options.0?.new-option == \undefined => 0

            | _ =>

                # highlight the first option if the remaining are not selectable
                if (options
                    |> drop 1
                    |> all -> (typeof it.selectable == \boolean) and !it.selectable)
                    0

                # alas, highlight the second option 
                # happens when:
                #  the first option is coming from `create-from-search` prop AND
                #  number of options are greater than 1 AND
                #  the second option is selectable
                else
                    1

    # focus :: () -> ()
    focus: !-> @refs.select.focus!

    # blur :: () -> ()
    blur: !-> @refs.select.blur!

    # highlight-the-first-selectable-option :: () -> ()
    highlight-first-selectable-option: !->
        if @state.open
            @refs.select.highlight-and-scroll-to-selectable-option do 
                @first-option-index-to-highlight @get-computed-state!.options
                1

    # value :: () -> Item
    values: -> if @props.has-own-property \values then @props.values else @state.values

    # is-open :: () -> Boolean
    is-open: -> if @props.has-own-property \open then @props.open else @state.open