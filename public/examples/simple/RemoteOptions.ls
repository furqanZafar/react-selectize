create-react-class = require \create-react-class
Form = create-react-class do
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            ref: \select
            placeholder: "Select a library"
            options: @state.libraries
            search: @state.search
            
            # on-search-change :: String -> (a -> Void) -> Void
            on-search-change: (search) !~>
                @set-state {search}
                
                if search.length > 0

                    if !!@req
                        @req.abort

                    @req = $.getJSON "http://api.cdnjs.com/libraries?fields=version,homepage&search=#{search}"
                        ..done ({results}) ~>
                            @set-state do 
                                libraries: take 50, (results ? [])
                                ~> @refs.select.highlight-first-selectable-option!
                            delete @req
            
            # disable client side filtering
            # filter-options :: [Item]  -> String -> [Item]
            filter-options: (options, search) -> options
            
            uid: (.name)

            render-option: ({name, latest, version, homepage}) ~>
                div class-name: \simple-option, style: font-size: 12,
                    div null,
                        span style: font-weight: \bold, name
                        span null, "@#{version}"
                    div null, 
                        a {href: homepage, target: \blank}, homepage
                        
            render-value: ({name, version}) ~>
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
                
render (React.create-element Form, null), mount-node