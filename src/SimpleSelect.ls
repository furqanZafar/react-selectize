{all, any, drop, camelize, difference, filter, find, find-index, id, last, map, reject} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
{create-factory, DOM:{div, img, span}}:React = require \react
ReactSelectize = create-factory require \./ReactSelectize

module.exports = React.create-class do

    display-name: \SimpleSelect

    # get-default-props :: () -> Props
    get-default-props: ->
        # autofocus :: Boolean
        # class-name :: String
        # create-from-search :: [Item] -> String -> Item?
        # disabled :: Boolean
        delimiters: []
        # editable :: Item -> String
        # filter-options :: [Item] -> String -> [Item]
        filter-options: (options, search) -->  
            options
                |> filter ~> (it.label.to-lower-case!.trim!.index-of search.to-lower-case!.trim!) > -1
        # name :: String
        on-blur: ((e) !->) # :: # Event -> ()
        on-focus: ((e) !->) # :: Event -> ()
        on-keyboard-selection-failed: ((which) !-> ) # :: Int -> ()
        # on-search-change :: String -> ()
        # on-value-change :: Item -> () 
        # open :: Boolean
        # options :: [Item]
        # on-open-change :: Boolean -> ()
        placeholder: ""
        # render-no-results-found :: Item -> String -> ReactElement
        # render-option :: Int -> Item -> ReactElement
        # render-value :: Int -> Item -> ReactElement
        render-value: ({label}) -> 
            div do 
                class-name: \simple-value
                span null, label

        # restore-on-backspace :: Item -> String
        # search :: String
        serialize: (?.value)
        style: {}
        tether: false
        uid: id # uid :: (Equatable e) => Item -> e
        # value :: Item

    # render :: () -> ReactElement
    render: -> 
        
        # computed state
        {
            filtered-options, on-open-change, on-search-change, on-value-change, open, options, search, value, values
        } = @get-computed-state!

        # props
        {
            autofocus, autosize, delimiters, disabled, dropdown-direction, group-id, groups, groups-as-columns, 
            name, render-group-title, serialize, tether, transition-enter, transition-leave, transition-enter-timeout, 
            transition-leave-timeout, uid
        }? = @props
            
        # if the user hits the return key on an empty dropdown, then hide the dropdown and clear the search text
        
        ReactSelectize {
            
            autofocus
            autosize
            class-name: "simple-select" + if !!@props.class-name then " #{@props.class-name}" else ""
            delimiters
            disabled
            dropdown-direction
            group-id
            groups
            groups-as-columns
            name
            render-group-title
            tether
            transition-enter
            transition-enter-timeout
            transition-leave
            transition-leave-timeout

            ref: \select

            # ANCHOR
            anchor: last values
            on-anchor-change: (, callback) ~> callback!

            # OPEN
            open: open
            on-open-change: on-open-change

            # HIGHLIGHTED OPTION
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

                    # deselect 
                    <~ on-value-change undefined
                    callback!

                else
                    # check if the new value differs from the old
                    new-value = last new-values
                    changed = !(new-value `is-equal-to-object` value)

                    # invoke on-value-change if new value differs from the old
                    <~ do ~> (callback) ~> if changed then on-value-change new-value, callback else callback!
                    callback!

                    # close dropdown but keep the input field in foucs
                    <~ on-open-change false
            render-value: (item) ~>

                # hide the selected value only when:
                #  the dropdown is open and 
                #   either the search-string length is > 0 or 
                #   selected value is editable
                if open and (!!@props.editable or search.length > 0)
                    null

                # always show the selected value when the dropdown is closed 
                else
                    @props.render-value item
            on-keyboard-selection-failed: (which) ~>
                <~ on-search-change ""
                <~ on-open-change false
                @props.on-keyboard-selection-failed which

            # TODO: distinguish between uid for selected value & option, this will improve performance
            #  by not having to compare against additional open & search properties added to uid below
            uid: (item) ~> 

                # add open and search to uid since the render-value above depends on them
                uid: @props.uid item
                open: open
                search: search

            # FORM SERIALIZATION
            serialize: (items) ~> serialize items.0

            # BLUR & FOCUS
            on-blur: (e) !~> 
                # clear the search text
                <~ do ~> 
                    (callback) ~> 
                        if search.length > 0 
                            on-search-change "", callback 

                        else 
                            callback!

                # fire on-blur event
                @props.on-blur {value, open, original-event: e}
            on-focus: (e) !~> @props.on-focus {value, open, original-event: e}

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

    # get-computed-state :: () -> UIState
    get-computed-state: ->

        # decide whether to use state or props
        open = @is-open!
        search = if @props.has-own-property \search then @props.search else @state.search
        value = @value!
        values = if !!value then [value] else []
        
        # on-*-change :: a -> (() -> ()) -> ()
        [on-open-change, on-search-change, on-value-change] = <[open search value]> |> map (p) ~>
            result = switch

                # both p & its change callback are coming from props
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
                        <~ @set-state {"#{p}" : o}
                        callback!

                        @props[camelize "on-#{p}-change"] o, (->)

                # both p and its change callback are coming from state
                # update the state & on success invoke the change callback
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

        # the final list of options is the concatination of any new-option, created from search, or [] with 
        # the list of filtered options
        options = (if !!new-option then [{} <<< new-option <<< new-option: true] else []) ++ filtered-options

        {
            open
            search
            value
            values

            # on-open-change :: Boolean -> (() -> ()) -> ()
            on-open-change: (open, callback) !~>
                <~ on-open-change open
                callback!
                
                # if props.editable is defined, then populate the search field with the result of `props.editable selected-value`
                if !!@props.editable and (@is-open! and !!value)
                    <~ on-search-change "#{@props.editable value}#{if search.length == 1 then search else ''}"
                    <~ @highlight-first-selectable-option

            on-search-change
            on-value-change
            filtered-options
            options
        }

    # get-initial-state :: () -> UIState
    get-initial-state: ->
        highlighted-uid: undefined
        open: false
        search: ""
        value: @props?.default-value

    # first-option-index-to-highlight :: [Item] -> Item -> Int
    first-option-index-to-highlight: (options, value) ->

        # find the index of the currently selection option (if any)
        index = if !!value then (find-index (~> it `is-equal-to-object` value), options) else undefined

        switch
            # highlight the currently select option (if any)
            | typeof index != \undefined => index

            # highlight the first option if there is only one option            
            | options.length == 1 => 0

            # highlight the first option if isn't coming from (create-from-search prop)            
            | (typeof options.0?.new-option) == \undefined => 0

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

    # fires the on-focus event after moving the cursor to the search input (with the reason = function-call)
    # fires the callback after the dropdown becomes visible
    # focus :: (() -> ()) -> ()
    focus: !-> @refs.select.focus!

    # fires the on-blur event after closing the dropdown (with the reason = function-call)
    # blur :: Callback -> ()
    blur: !-> @refs.select.blur!

    # highlight-the-first-selectable-option :: (() -> ()) -> ()
    highlight-first-selectable-option: (callback = (->)) !->
        if @state.open
            {options, value} = @get-computed-state!
            @refs.select.highlight-and-scroll-to-selectable-option do 
                @first-option-index-to-highlight options, value
                1
                callback

        else
            callback!

    # value :: () -> Item
    value: -> if @props.has-own-property \value then @props.value else @state.value

    # is-open :: () -> Boolean
    is-open: -> if @props.has-own-property \open then @props.open else @state.open