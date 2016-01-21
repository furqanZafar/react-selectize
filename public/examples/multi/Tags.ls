Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect,
        
            values: @state.tags
            
            # 188 = comma
            # delimiters :: [KeyCode]
            delimiters: [188]
            
            # values-from-paste :: [Item] -> [Item] -> String -> [Item]
            values-from-paste: (options, values, pasted-text) ~>
                pasted-text
                |> Str.split \,
                |> reject ~> it in map (.label), values
                |> map ~> label: it, value: it
            
            # restore-on-backspace :: Item -> String
            restore-on-backspace: (.label)

            # on-values-change :: [Item] -> (a -> Void) -> Void
            on-values-change: (tags, callback) !~> @set-state {tags}, callback
            
            # create-from-search :: [Item] -> [Item] -> String -> Item?
            create-from-search: (options, values, search) -> 
                return null if search.trim!.length == 0 or search.trim! in map (.label), values
                label: search.trim!, value: search.trim!
                
            # render-no-results-found :: [Item] -> String -> ReactElement
            render-no-results-found: (values, search) ~> 
                div class-name: \no-results-found,
                    if search.trim!.length == 0
                        "Type a few characters to create a tag"
                    else if (search.trim! in map (.label), values)
                        "Tag already exists"
    
    # get-initial-state :: a -> UIState
    get-initial-state: ->
        tags: <[react d3]> |> map ~> label: it, value: it
                
render (React.create-element Form, null), mount-node