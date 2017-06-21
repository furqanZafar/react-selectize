create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect,
            
            # create-from-search :: [Item] -> [Item] -> String -> Item?
            create-from-search: (options, values, search) -> 
                return null if search.trim!.length == 0 or search.trim! in map (.label), values
                label: search.trim!, value: search.trim!
                
render (React.create-element Form, null), mount-node