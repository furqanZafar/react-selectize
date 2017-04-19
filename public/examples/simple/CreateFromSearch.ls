create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            options: @state.options
            placeholder: "Select a fruit"
            
            # create-from-search :: [Item] -> String -> Item?
            create-from-search: (options, search) ~> 
                # only create an option from search if the length of the search string is > 0 and
                # it does no match the label property of an existing option
                return null if search.length == 0 or search in map (.label), options
                label: search, value: search
            
            # on-value-change :: Item -> (a -> Void) -> Void
            on-value-change: ({label, value, new-option}?) !~>
                # here, we add the selected item to the options array, the "new-option"
                # property, added to items created by the "create-from-search" function above, 
                # helps us ensure that the item doesn't already exist in the options array
                if !!new-option
                    @set-state options: [{label, value}] ++ @state.options
                
    get-initial-state: ->
        options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
                
render (React.create-element Form, null), mount-node