# prelude ls
{each, filter, find, find-index, id, initial, last, map, obj-to-pairs,
partition, reject, reverse, Str, sort-by, sum, values} = require \prelude-ls

{clamp, is-equal-to-object} = require \prelude-extension
{DOM:{div, input, path, span, svg}, create-class, create-factory}:React = require \react
{find-DOM-node} = require \react-dom
ReactCSSTransitionGroup = create-factory require \react-addons-css-transition-group
ToggleButton = create-factory require \./ToggleButton
DropdownMenu = create-factory require \./DropdownMenu
OptionWrapper = create-factory require \./OptionWrapper
ValueWrapper = create-factory require \./ValueWrapper
ResetButton = create-factory require \./ResetButton
ResizableInput = create-factory require \./ResizableInput
{cancel-event, class-name-from-object} = require \./utils

module.exports = create-class do

    display-name: \ReactSelectize

    # used to figure out if the focus event was triggered by external action or by @focus-on-input!
    focus-lock: false

    # get-default-props :: () -> Props
    get-default-props: ->
        anchor: null # :: Item
        autofocus: false
        cancel-keyboard-event-on-selection: true
        # class-name :: String
        delimiters: []
        disabled: false
        maxLength: 255
        dropdown-direction: 1
        first-option-index-to-highlight: (options) -> 0
        group-id: (.group-id) # Item -> a
        # groups :: [Group]
        groups-as-columns: false
        highlighted-uid: undefined
        input-props: {}
        # name :: String, used for creating hidden input element
        on-anchor-change: ((anchor) ->) # Item -> (() -> ()) -> ()
        on-blur: ((e) !->) # Event -> ()
        on-enter: ((highlighted-option) !->) # Item -> ()
        on-focus: ((e) !->) # Event -> ()
        on-highlighted-uid-change: ((uid, callback) !-> ) # (Eq e) => e -> (() -> ()) -> ()
        on-keyboard-selection-failed: ((keycode) !-> ) # Int -> ()
        on-open-change: ((open, callback) !->) # Boolean -> (() -> ()) -> ()
        on-paste: ((e) !-> true) # Event -> Boolean
        on-scroll-lock-change: ((scroll-lock) !->) # Boolean -> ()
        on-search-change: ((search, callback) !-> ) # String -> (() -> ()) -> ()
        on-values-change: ((values, callback) !->) # [Item] -> (() -> ()) -> ()
        open: false
        # options :: [Item]
        # render-no-results-found :: () -> ReactElement
        # render-group-title :: Int -> Group -> ReactElement
        # render-option :: Int -> Item -> ReactElement
        hide-reset-button: false

        # render-value :: Int -> Item -> ReactElement
        render-value: ({label}) ->
            div do
                class-name: \simple-value
                span null, label

        # render-toggle-button :: ({open :: Boolean, flipped :: Boolean}) -> ReactElement
        render-toggle-button: ToggleButton

        # render-reset-button :: () -> ReactElement
        render-reset-button: ResetButton

        # restore-on-backspace: ((value) -> ) # Item -> String

        # used to block default behaviour of option.mouseover when triggered by scrolling using arrow keys
        scroll-lock: false

        # serialize :: [Item] -> String, used for form serialization
        search: ""
        style: {}
        # tether :: Boolean
        # tether-props :: {parent-element :: () -> DOMElement}
        # transition-enter :: Boolean
        # transition-leave :: Boolean
        # transition-enter-timeout :: Int
        # transition-leave-timeout :: Int
        theme: \default
        uid: id # (Eq e) => Item -> e
        values: [] # [Item]

    # render :: () -> ReactElement
    render: ->
        anchor-index =
            | (typeof @props.anchor == \undefined) or @props.anchor == null => -1
            | _ => (find-index (~> it `@is-equal-to-object` @props.anchor), @props.values) ? @props.values.length - 1

        # render-selected-values :: [Int] -> [ValueWrapper]
        render-selected-values = (selected-values) ~>
            selected-values |> map (index) ~>
                item = @props.values[index]
                uid = @props.uid item
                ValueWrapper do
                    key: @uid-to-string uid
                    uid: uid
                    item: item
                    render-item: @props.render-value

        flipped = @props.dropdown-direction == -1

        # REACT SELECTIZE
        div do
            class-name: class-name-from-object do
                \react-selectize : 1
                "#{@props.theme}" : 1
                \root-node : 1
                "#{@props.class-name}" : 1
                disabled: @props.disabled
                maxLength: @props.maxLength
                open: @props.open
                flipped: flipped
                tethered: @props.tether

            style: @props.style

            if !!@props.name

                # HIDDEN INPUT (for form submission)
                input do
                    type: \hidden
                    name: @props.name
                    value: @props.serialize @props.values

            # CONTROL
            div do
                class-name: \react-selectize-control
                ref: \control

                # using click would cause a flicker because:
                # 1: on mouse down, the focus will blur from the search field causing the dropdown menu to close
                # 2: on mouse up, the click event will be fired and open the dropdown menu again
                # on mouse down, we have to cancel the event otherwise the search field would cause the same problem above
                on-mouse-down: (e) ~>
                    do ~>
                        <~ @props.on-anchor-change last @props.values
                        <~ @on-open-change true
                        @highlight-and-focus!

                    # avoid cancelling the event when the dropdown is already open
                    # as this would block selection of text in the search field
                    if !@props.open
                        cancel-event e

                if @props.search.length == 0 and @props.values.length == 0

                    # PLACEHOLDER
                    div class-name: \react-selectize-placeholder, @props.placeholder

                div do
                    class-name: \react-selectize-search-field-and-selected-values

                    # LIST OF SELECTED VALUES (BEFORE & INCLUDING THE ANCHOR)
                    render-selected-values [0 to anchor-index]

                    # SEARCH INPUT BOX
                    ResizableInput do
                        {disabled: @props.disabled} <<< @props.input-props <<< {
                            ref: \search
                            type: \text
                            value: @props.search
                            maxLength: @props.maxLength

                            # update the search text & highlight the first option
                            on-change: ({current-target:{value}}) ~>
                                @props.on-search-change value, ~>
                                    @highlight-and-scroll-to-selectable-option do
                                        @props.first-option-index-to-highlight @props.options
                                        1

                            # show the list of options (noop if caused by invocation of @focus-on-input function)
                            on-focus: (e) !~>
                                # @focus-lock propery is set to true by invoking the @focus-on-input! method
                                # if @focus-lock is false, it implies this focus event was fired as a result of an external action
                                <~ do ~> (callback) ~>
                                    if !!@focus-lock
                                        callback @focus-lock = false

                                    else
                                        <~ @on-open-change true
                                        callback true

                                # invokes on-focus listener with the reason depending on the value of @focus-lock
                                @props.on-focus e

                            on-blur: (e) ~>
                                # to prevent closing the dropdown when the user tries to click & drag the scrollbar in IE
                                return if @refs.dropdown-menu and document.active-element == (find-DOM-node @refs.dropdown-menu)

                                <~ @close-dropdown

                                # fire on-blur event listener
                                @props.on-blur e

                            # on-paste :: Event -> Boolean
                            on-paste: @props.on-paste

                            # on-key-down :: Event -> Boolean
                            on-key-down: (e) ~> @handle-keydown {anchor-index}, e
                        }

                    # LIST OF SELECTED VALUES (AFTER THE ANCHOR)
                    render-selected-values [anchor-index + 1 til @props.values.length]

                if @props.values.length > 0 and !@props.hide-reset-button

                    # RESET BUTTON
                    div do
                        class-name: \react-selectize-reset-button-container
                        on-click: (e) ~>
                            do ~>
                                <~ @props.on-values-change []
                                <~ @props.on-search-change ""
                                @highlight-and-focus!
                            cancel-event e
                        @props.render-reset-button!

                # TOGGLE BUTTON
                div do
                    class-name: \react-selectize-toggle-button-container
                    on-mouse-down: (e) ~>
                        if @props.open
                            @on-open-change false, ~>
                        else
                            <~ @props.on-anchor-change last @props.values
                            <~ @on-open-change true
                        cancel-event e
                    @props.render-toggle-button do
                        open: @props.open
                        flipped: flipped


            # (TETHERED / ANIMATED / SIMPLE) DROPDOWN
            DropdownMenu {} <<< @props <<<
                ref: \dropdownMenu
                class-name: class-name-from-object do
                    \react-selectize : 1
                    "#{@props.class-name}" : 1
                theme: @props.theme

                # scroll-lock is used for blocking mouse interference with highlighted uid when using the arrow keys
                # to scroll through the options list
                scroll-lock: @props.scroll-lock
                on-scroll-change: @props.on-scroll-change

                # used when dropdown-direction is -1
                # bottom-anchor :: () -> ReactElement
                bottom-anchor: ~> find-DOM-node @refs.control

                tether-props: {} <<< @props.tether-props <<<

                    # used when @props.tether is true
                    # target :: () -> ReactElement
                    target: ~> find-DOM-node @refs.control

                # uid of the highlighted option, this changes whenever the user hovers over an option
                # or uses arrow keys to navigate the list of options
                highlighted-uid: @props.highlighted-uid
                on-highlighted-uid-change: @props.on-highlighted-uid-change

                # on-option-click :: (Eq e) => e -> ()
                on-option-click: (highlighted-uid) !~>
                    <~ @select-highlighted-uid anchor-index


    # handle-keydown :: ComputedState -> Event -> Boolean
    handle-keydown: ({anchor-index}, e) ->
        e.persist()

        # always handle the tab, backspace & escape keys
        switch e.which

        # BACKSPACE
        | 8 =>

            return if @props.search.length > 0 or anchor-index == -1

            do ~>
                # compute the next-anchor
                anchor-index-on-remove = anchor-index
                next-anchor = if (anchor-index - 1) < 0 then undefined else @props.values[anchor-index - 1]

                # remove the item at the current carret position,
                # by requesting the user to update the values array,
                # via (@props.on-value-change new-values, callback)
                value-to-remove = @props.values[anchor-index]
                <~ @props.on-values-change do
                    (@props.values |> reject ~> it `@is-equal-to-object` value-to-remove) ? []

                # result is true if the user removed the value we requested him to remove
                result <~ do ~> (callback) ~>

                    if typeof (find (~> it `@is-equal-to-object` value-to-remove), @props.values) == \undefined

                        if !!@props.restore-on-backspace
                            <~ @props.on-search-change @props.restore-on-backspace value-to-remove
                            callback true

                        else
                            callback true

                    else
                        callback false

                if !!result

                    # highlight the first option in the dropdown
                    @highlight-and-scroll-to-selectable-option do
                        @props.first-option-index-to-highlight @props.options
                        1

                    # change the anchor iff the user removed the requested value
                    # and the predicted next-anchor is still present
                    if anchor-index == anchor-index-on-remove and (
                        typeof next-anchor == \undefined or
                        !!(@props.values |> find ~> it `@is-equal-to-object` next-anchor)
                    )
                       <~ @props.on-anchor-change next-anchor

            cancel-event e

        # ESCAPE
        | 27 =>
            # first hit closes the list of options, second hit will reset the selected values
            <~ do ~>
                if @props.open
                    ~> @on-open-change false, it
                else
                    ~> @props.on-values-change [], it
            <~ @props.on-search-change ""
            @focus-on-input!

        # ENTER
        if @props.open and
           e.which in [13] ++ @props.delimiters and
           # do not interfere with hotkeys like control + enter or command + enter
           !(e?.meta-key or e?.ctrl-key or e?.shift-key)

            # select the highlighted option (if any)
            result = @select-highlighted-uid anchor-index, (selected-value) ~>
                if typeof selected-value == \undefined
                    @props.on-keyboard-selection-failed e.which

            if result and @props.cancel-keyboard-event-on-selection
                return cancel-event e

        # move anchor position left / right using arrow keys (only when search field is empty)
        if @props.search.length == 0

            switch e.which

            # LEFT ARROW
            | 37 =>
                @props.on-anchor-change do
                   if ((anchor-index - 1) < 0 or e.meta-key)
                       undefined
                   else
                       @props.values[clamp (anchor-index - 1), 0, (@props.values.length - 1)]
                   (->)

            # RIGHT ARROW
            | 39 =>
                @props.on-anchor-change do
                   if e.meta-key
                       last @props.values
                   else
                       @props.values[clamp (anchor-index + 1), 0, (@props.values.length - 1)]
                   (->)

        switch e.which

            # wrap around upon hitting the boundary
            # UP ARROW
            | 38 =>
                @props.on-scroll-lock-change true
                index =
                    | typeof @props.highlighted-uid == \undefined => 0
                    | _ => -1 + @option-index-from-uid @props.highlighted-uid
                result <~ @highlight-and-scroll-to-selectable-option index, -1
                if !result
                    @highlight-and-scroll-to-selectable-option (@props.options.length - 1), -1

            # DOWN ARROW
            | 40 =>
                @props.on-scroll-lock-change true
                index =
                    | typeof @props.highlighted-uid == \undefined => 0
                    | _ => 1 + @option-index-from-uid @props.highlighted-uid
                result <~ @highlight-and-scroll-to-selectable-option index, 1
                if !result
                    @highlight-and-scroll-to-selectable-option 0, 1

    # component-did-mount :: () -> ()
    component-did-mount: !->
        if @props.autofocus
            @focus!

        # if the dropdown menu is open on mount, then highlight the first selectable option
        # and focus on the search input, just like we would when it is opened by external action
        if @props.open
            @highlight-and-focus!

    # component-did-update :: Props -> UIState -> ()
    component-did-update: (prev-props) !->

        # if the list of options opened then highlight the first option & focus on the search input
        if @props.open and !prev-props.open and @props.highlighted-uid == undefined
            @highlight-and-focus!

        # if the list of options was closed then reset highlighted-uid
        if !@props.open and prev-props.open
            <~ @props.on-highlighted-uid-change undefined

    # component-will-receive-props :: Props -> ()
    component-will-receive-props: (props) !->
        if (typeof @props.disabled == \undefined or @props.disabled == false) and
           (typeof props.disabled != \undefined and props.disabled == true)
           @on-open-change false, ~>

    # option-index-from-uid :: (Eq e) => e -> Int
    option-index-from-uid: (uid) -> @props.options |> find-index ~> uid `is-equal-to-object` @props.uid it

    # close-dropdown :: (() -> ()) -> ()
    close-dropdown: (callback) !->
        <~ @on-open-change false
        @props.on-anchor-change do
            last @props.values
            callback

    # blur :: () -> ()
    blur: !-> @refs.search.blur!

    # focus :: () -> ()
    focus: !-> @refs.search.focus!

    # move the cursor to the input field, without toggling the dropdown
    # focus-on-input :: () -> ()
    focus-on-input: !->
        input = find-DOM-node @refs.search
        if input != document.active-element
            @focus-lock = true

            # this triggers the DOM focus event on the input control, where we use @focus-lock to determine
            # if the event was triggered by external action or by invoking @focus-on-input method.
            input.focus!

            # move the cursor to the end of the search field
            input.value = input.value

    # highlights the first selectable option & moves the cursor to end of the search field
    # highlight-and-focus :: () -> ()
    highlight-and-focus: !->
        @highlight-and-scroll-to-selectable-option do
            @props.first-option-index-to-highlight @props.options
            1
        @focus-on-input!

    # highlight-and-scroll-to-option :: Int, (() -> ())? -> ()
    highlight-and-scroll-to-option: (index, callback = (->)) !->
        @refs.dropdown-menu.highlight-and-scroll-to-option index, callback

    # highlight-and-scroll-to-selectable-option :: Int, Int, (Boolean -> ())? -> ()
    highlight-and-scroll-to-selectable-option: (index, direction, callback = (->)) !->

        # open dropdown menu
        <~ do ~> if !@props.open then (~> @on-open-change true, it) else (-> it!)
        @refs.dropdown-menu.highlight-and-scroll-to-selectable-option index, direction, callback

    # is-equal-to-object :: Item -> Item -> Boolean
    is-equal-to-object: --> (@props.uid &0) `is-equal-to-object` @props.uid &1

    # on-open-change :: Boolean -> (() -> ()) -> ()
    on-open-change: (open, callback) ->
        @props.on-open-change do
            if @props.disabled then false else open
            callback

    # select-highlighted-uid :: Int -> Boolean
    select-highlighted-uid: (anchor-index, callback) ->
        # return if there isn't any highlighted / focused option
        if @props.highlighted-uid == undefined
            callback!
            return false

        # sanity check
        index = @option-index-from-uid @props.highlighted-uid
        if typeof index != \number
            callback!
            return false

        option = @props.options[index]

        do ~>

            # values = (values behind & including the anchor) + highlighted option + (values ahead of the anchor)
            <~ @props.on-values-change do
                (map (~> @props.values[it]), [0 to anchor-index]) ++
                [option] ++
                (map (~> @props.values[it]), [anchor-index + 1 til @props.values.length])

            value = find (~> it `@is-equal-to-object` option), @props.values
            if !value
                callback!
                return

            # if the user did what we asked, then clear the search and move the anchor ahead of the selected value
            <~ @props.on-search-change ""
            <~ @props.on-anchor-change value
            if !@props.open
                callback value
                return

            # highlight the next selectable option
            result <~ @highlight-and-scroll-to-selectable-option index, 1
            if !!result
                callback value
                return

            # if there are no highlightable/selectable options (then close the dropdown)
            result <~ @highlight-and-scroll-to-selectable-option do
                @props.first-option-index-to-highlight @props.options
                1
            if !result
                <~ @on-open-change false
                callback value
            else
                callback value

        true

    # uid-to-string :: () -> String, only used for the key prop (required by react render), & for refs
    uid-to-string: (uid) -> (if typeof uid == \object then JSON.stringify else id) uid
