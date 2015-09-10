Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element MultiSelect, 
            placeholder: "Select 3 emojis"
            max-values: 3
            
            # restore-on-backspace :: Item -> String
            restore-on-backspace: (.label)
            options: @state.emojis
            values: @state.selected-emojis
            
            # on-values-change :: [Item] -> (a -> Void) -> Void
            on-values-change: (selected-emojis, callback) !~> @set-state {selected-emojis}, callback
            
            # filter-options :: [Item] -> [Item] -> String -> [Item]
            filter-options: (options, values, search) ~>
                char-map =
                    ':)' : \smile, ':(' : \frowning, \:D : \grin
                    ':((' : \disappointed, \:P : \stuck_out_tongue, ';)' : \wink
                    \<3 : \heart, \o.O : \confused, ':o' : \open_mouth
                    \:* : \kissing, \B| : \sunglasses
                if !!char-map[search] 
                    options |> filter (.label == char-map[search])
                else
                    options 
                        |> reject ({value}) -> value in map (.value), values 
                        |> filter ({label}) -> (label.index-of search) == 0
                        |> take 50
                
            # render-option :: Int -> Item -> ReactElement
            render-option: (index, {label, value}) ~>
                div class-name: \simple-option,
                    img src: value, style: margin-right: 4, vertical-align: \middle, width: 24
                    span null, label
                    
            # render-value :: Int -> Item -> ReactElement
            render-value: (index, {label, value}) ~>
                div class-name: \simple-value,
                    span do 
                        on-click: ~> @set-state do 
                            selected-emojis: @state.selected-emojis |> reject ~> it.value == value
                        \x
                    img src: value, style: margin-right: 4, vertical-align: \middle, width: 24
            
    # get-initial-state :: a -> UIState
    get-initial-state: -> emojis: [], selected-emojis: []
    
    # component-will-mount :: a -> Void
    component-will-mount: !->
        $.getJSON \https://api.github.com/emojis
            ..done (result) ~>
                @set-state do 
                    emojis: result
                    |> obj-to-pairs
                    |> map ([label, value]) -> {label, value}

React.render (React.create-element Form, null), mount-node