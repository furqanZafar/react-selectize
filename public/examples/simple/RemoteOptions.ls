Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            placeholder: "Select a library"
            options: @state.libraries
            search: @state.search
            
            # on-search-change :: String -> (a -> Void) -> Void
            on-search-change: (search, callback) !~>
                @set-state {search}, callback
                return if search.length == 0
                @req.abort if !!@req
                @req = $.getJSON "http://api.cdnjs.com/libraries?fields=version,homepage&search=#{search}"
                    ..done ({results}) ~>
                        @set-state libraries: take 50, (results ? [])
                        delete @req
            
            # filter-options :: [Item] -> Item -> String -> [Item]
            filter-options: (options, value, search) -> options
            
            render-option: (index, {name, latest, version, homepage}) ~>
                div class-name: \simple-option, style: font-size: 12,
                    div null,
                        span style: font-weight: \bold, name
                        span null, "@#{version}"
                    div null, 
                        a {href: homepage, target: \blank}, homepage
                        
            render-value: (index, {name, version}) ~>
                div class-name: \simple-value,
                    span style: font-weight: \bold, name
                    span null, "@#{version}"
                     
            # render-no-results-found :: Item -> String -> ReactElement
            render-no-results-found: (value, search) ~>
                div class-name: \no-results-found, style: font-size: 13,
                    if typeof @req == \undefined and @state.search.length == 0
                        "type a few characters to kick off remote search"
                    else
                        "No results found"
                        
    get-initial-state: ->
        libraries: []
        search: ""
                
React.render (React.create-element Form, null), mount-node