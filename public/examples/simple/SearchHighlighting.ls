# {partition-string} = require \prelude-extension
# {HighlightedText, SimpleSelect} = require \ReactSelectize

Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            
            # we use state for search, so we can access it inside the options map function below
            search: @state.search
            on-search-change: (search, callback) ~> @set-state {search}, callback
            
            # the partition-string method from prelude-extension library has the following signature:
            # paritition-string :: String -> String -> [[Int, Int, Boolean]]
            options: <[apple mango grapes melon strawberry]> |> map ~> 
                label: it, value: it, label-partitions: partition-string it, @state.search
            
            # we add the search to the uid property of each option
            # to re-render it whenever the search changes
            # uid :: (Equatable e) => Item -> e
            uid: ~> "#{it.value}#{@state.search}"
            
            # here we use the HighlightedText component to render the result of partition-string
            # render-option :: Item -> ReactElement
            render-option: ({label, label-partitions}) ~>
                div class-name: \simple-option,
                    React.create-element HighlightedText,
                        partitions: label-partitions, 
                        text: label
                        highlight-style:
                            background-color: "rgba(255,255,0,0.4)"
                            font-weight: \bold
                        
            placeholder: "Select a fruit"
    
    # get-initial-state :: a -> UIState
    get-initial-state: ->
        search: ""

render (React.create-element Form, null), mount-node