# prelude ls 
{filter, id, map} = require \prelude-ls

{is-equal-to-object} = require \prelude-extension
{DOM:{div, input, span}, create-class, create-factory}:React = require \react
{find-DOM-node} = require \react-dom
ReactCSSTransitionGroup = create-factory require \react-addons-css-transition-group
ReactTether = create-factory require \./ReactTether
DivWrapper = create-factory require \./DivWrapper
OptionWrapper = create-factory require \./OptionWrapper
{cancel-event, class-name-from-object} = require \./utils

module.exports = create-class do

    display-name: \DropdownMenu

    # get-default-props :: () -> Props
    get-default-props: ->
        # bottom-anchor :: () -> ReactElement
        class-name: ""
        dropdown-direction: 1
        group-id: (.group-id) # Item -> a
        # groups :: [Group]
        groups-as-columns: false
        highlighted-uid: undefined
        # name :: String, used for creating hidden input element
        on-highlighted-uid-change: ((uid, callback) !-> ) # (Eq e) => e -> (() -> ()) -> ()
        on-option-click: ((uid) !->) # (Eq e) => e -> ()
        on-scroll-lock-change: ((scroll-lock) !-> ) # Boolean -> ()
        options: [] # [Item]
        
        # render-no-results-found :: () -> ReactElement
        render-no-results-found: -> 
            div class-name: \no-results-found, "No results found"
        
        # render-group-title :: Int -> Group -> ReactElement
        render-group-title: (index, {group-id, title}?) ->
            div do
                class-name: \simple-group-title
                key: group-id
                title
        
        # render-option :: Int -> Item -> ReactElement
        render-option: ({label, new-option, selectable}?) ->
            is-selectable = (typeof selectable == \undefined) or selectable
            div do 
                class-name: "simple-option #{if is-selectable then '' else 'not-selectable'}"
                span null, if !!new-option then "Add #{label} ..." else label
        
        scroll-lock: false
        style: {}
        tether: false
        # tether-props :: {parent-element :: () -> DOMElement}
        tether-props: {}
        theme: \default
        transition-enter: false
        transition-leave: false
        transition-enter-timeout: 200
        transition-leave-timeout: 200
        uid: id # (Eq e) => Item -> e

    # render :: () -> ReactElement
    render: ->
        dynamic-class-name = class-name-from-object do
            "#{@props.theme}" : 1
            "#{@props.class-name}" : 1
            flipped: @props.dropdown-direction == -1
            tethered: @props.tether

        # (TETHERED / ANIMATED / SIMPLE) DROPDOWN
        if @props.tether 
            ReactTether do
                {} <<< @props.tether-props <<<
                    options:
                        attachment: "top left"
                        target-attachment: "bottom left"
                        constraints:
                            * to: \scrollParent
                            ...
                @render-animated-dropdown {dynamic-class-name}

        else
            @render-animated-dropdown {dynamic-class-name}

    # render-animated-dropdown :: ComputedState -> ReactElement
    render-animated-dropdown: ({dynamic-class-name}:computed-state) ->
        if !!@props.transition-enter or !!@props.transition-leave
            ReactCSSTransitionGroup do 
                component: \div
                transition-name: \custom 
                transition-enter: @props.transition-enter
                transition-leave: @props.transition-leave
                transition-enter-timeout: @props.transition-enter-timeout
                transition-leave-timeout: @props.transition-leave-timeout
                class-name: "dropdown-menu-wrapper #{dynamic-class-name}"
                ref: \dropdownMenuWrapper
                @render-dropdown computed-state

        else
            @render-dropdown computed-state

    # render-options :: [Item] -> [ReactEleent]
    render-options: (options) ->
        [0 til options.length] |> map (index) ~>
            option = options[index]
            uid = @props.uid option

            # OPTION WRAPPER 
            OptionWrapper do
                {
                    uid
                    ref: "option-#{@uid-to-string uid}"
                    key: @uid-to-string uid
                    item: option
                    highlight: @props.highlighted-uid `is-equal-to-object` uid
                    selectable: option?.selectable
                    
                    on-mouse-move: ({current-target}) !~> 
                        if @props.scroll-lock
                            @props.on-scroll-lock-change false
                    
                    on-mouse-out: !~>  
                        if !@props.scroll-lock
                            <~ @props.on-highlighted-uid-change undefined

                    render-item: @props.render-option
                } <<<
                    switch
                    | (typeof option?.selectable == \boolean) and !option.selectable => on-click: cancel-event
                    | _ =>
                        on-click: !~> 
                            if !@props.scroll-lock
                                <~ @props.on-highlighted-uid-change uid
                            @props.on-option-click @props.highlighted-uid
                        on-mouse-over: ({current-target}) !~>  
                            if 'ontouchstart' of window => return false
                            if !@props.scroll-lock
                                <~ @props.on-highlighted-uid-change uid

    # render-dropdown :: ComputedState -> ReactElement
    render-dropdown: ({dynamic-class-name}) ->
        if @props.open
            
            # DROPDOWN
            DivWrapper do 
                class-name: "dropdown-menu #{dynamic-class-name}"
                ref: \dropdownMenu

                # on-height-change :: Number -> ()
                on-height-change: (height) !~> 
                    if @refs.dropdown-menu-wrapper
                        find-DOM-node @refs.dropdown-menu-wrapper .style.height = "#{height}px"

                # NO RESULT FOUND   
                if @props.options.length == 0
                    @props.render-no-results-found!
                
                else if @props?.groups?.length > 0

                    # convert [Group] to [{index: Int, group: Group, options: [Item]}]
                    groups = [0 til @props.groups.length] |> map (index) ~>  
                        {group-id}:group = @props.groups[index]
                        options = @props.options |> filter ~> (@props.group-id it) == group-id
                        {index, group, options}

                    # GROUPS
                    div class-name: "groups #{if !!@props.groups-as-columns then 'as-columns' else ''}",
                        groups 
                        |> filter (.options.length > 0)
                        |> map ({index, {group-id}:group, options}) ~>

                            # GROUP
                            div key: group-id,
                                @props.render-group-title index, group, options

                                # OPTIONS
                                div do 
                                    class-name: \options
                                    @render-options options

                else

                    # OPTIONS
                    @render-options @props.options

        else
            null

    # component-did-update :: () -> ()
    component-did-update: !->
        dropdown-menu = find-DOM-node @refs.dropdown-menu-wrapper ? @refs.dropdown-menu
            ..?style.bottom = switch 
                | @props.dropdown-direction == -1 => 
                    "#{@props.bottom-anchor!.offset-height + dropdown-menu.style.margin-bottom}px"
                    
                | _ => ""

    # highlight-and-scroll-to-option :: Int, (() -> ())? -> ()
    highlight-and-scroll-to-option: (index, callback = (->)) !->

        # update the focused option
        uid = @props.uid @props.options[index]
        <~ @props.on-highlighted-uid-change uid

        option-element? = find-DOM-node @refs?["option-#{@uid-to-string uid}"]

        if !!option-element
            parent-element = find-DOM-node @refs.dropdown-menu
            option-height = option-element.offset-height - 1

            # in other words, if the option element is below the visible region
            if (option-element.offset-top - parent-element.scroll-top) >= parent-element.offset-height

                # scroll the option element into view, by scrolling the parent element downward by an amount equal to the
                # distance between the bottom-edge of the parent-element and the bottom-edge of the option element
                parent-element.scroll-top = option-element.offset-top - parent-element.offset-height + option-height

            # in other words, if the option element is above the visible region
            else if (option-element.offset-top - parent-element.scroll-top + option-height) <= 0

                # scroll the option element into view, by scrolling the parent element upward by an amount equal to the
                # distance between the top-edge of the option element and the top-edge of the parent element
                parent-element.scroll-top = option-element.offset-top

        callback!

    # highlight-and-scroll-to-selectable-option :: Int, Int, (Boolean -> ())? -> ()
    highlight-and-scroll-to-selectable-option: (index, direction, callback = (->)) !->
        
        # end recursion if the index violates the bounds
        if index < 0 or index >= @props.options.length
            <~ @props.on-highlighted-uid-change undefined
            callback false

        else

            # recurse until a selectable option is found while moving in the given direction
            option = @props?.options?[index]
            if typeof option?.selectable == \boolean and !option.selectable
                @highlight-and-scroll-to-selectable-option index + direction, direction, callback

            # highlight the option found & end the recursion
            else
                <~ @highlight-and-scroll-to-option index
                callback true

    # uid-to-string :: () -> String, only used for the key prop (required by react render), & for refs
    uid-to-string: (uid) -> (if typeof uid == \object then JSON.stringify else id) uid
