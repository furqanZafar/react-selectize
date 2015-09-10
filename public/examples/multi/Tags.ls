Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect,
        
            values: @state.tags
            
            # on-values-change :: [Item] -> (a -> Void) -> Void
            on-values-change: (tags, callback) !~> @set-state {tags}, callback
            
            # create-from-search :: [Item] -> [Item] -> String -> Item?
            create-from-search: (options, values, search) -> 
                return null if search.length == 0 or search in map (.label), values
                label: search, value: search
                
            # render-no-results-found :: [Item] -> String -> ReactElement
            render-no-results-found: (values, search) ~> 
                div class-name: \no-results-found,
                    if search.length == 0
                        "Type a few characters to create a tag"
                    else if (search in map (.label), values)
                        "Tag already exists"
    
    # get-initial-state :: a -> UIState
    get-initial-state: ->
        tags: <[react d3]> |> map ~> label: it, value: it
                
React.render (React.create-element Form, null), mount-node