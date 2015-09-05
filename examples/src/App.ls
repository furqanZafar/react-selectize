$ = require \jquery-browserify
require \livescript
{compile} = require \livescript
{filter, find, fold, group-by, id, map, Obj, obj-to-pairs, pairs-to-obj, reject, Str, sort-by, take, unique, unique-by} = require \prelude-ls
{create-factory, DOM:{a, button, div, form, h1, h2, input, ol, li, span, ul}}:React = require \react
require! \react-tools
Example = create-factory require \./Example.ls
MultiSelect = create-factory require \MultiSelect.ls
SimpleSelect = require \SimpleSelect.ls

# 

examples = 
    * title: "Simple select"
      description: ""
      languages:
        jsx: """
Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this, 
            options = ["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
                return {label: fruit, value: fruit}
            });
        return <SimpleSelect options={options} placeholder="Select a fruit"></SimpleSelect>
    }
    
});

React.render(<Form/>, mountNode)
"""
        ls: """
Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select a fruit"
                
React.render (React.create-element Form, null), mount-node
"""
    * title: "Restore on backspace"
      description: "Press the [backspace] key and go back to editing the item without it being fully removed."
      languages:
        jsx: """
Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this, 
            options = ["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
                return {label: fruit, value: fruit}
            });
        return <SimpleSelect options={options} 
                             placeholder="Select a fruit"
                             
                             // restore-on-backspace :: Item -> String
                             restoreOnBackspace={function(item){
                                 return item.label.substr(0, item.label.length - 1)
                             }}>
        </SimpleSelect>
    }
    
});

React.render(<Form/>, mountNode)
"""
        ls: """
Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
            placeholder: "Select a fruit"
            
            # restore-on-backspace :: Item -> String
            restore-on-backspace: ~> it.label.substr 0, it.label.length - 1
                
React.render (React.create-element Form, null), mount-node
"""
    * title: "Create from search"
      description: ""
      languages:
        jsx: """
Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <SimpleSelect 
            options={this.state.options} 
            placeholder="Select a fruit"
                             
            // create-from-search :: [Item] -> String -> Item?
            createFromSearch={function(options, search){
                // only create an option from search if the length of the search string is > 0 and
                // it does no match the label property of an existing option
                if (search.length == 0 || (options.map(function(option){
                    return option.label;
                })).indexOf(search) > -1)
                    return null;
                else
                    return {label: search, value: search};
            }}
                             
            // on-value-change :: Item -> (a -> Void) -> Void
            onValueChange={function(item, callback){
                // here, we add the selected item to the options array, the "new-option"
                // property, added to items created by the "create-from-search" function above, 
                // helps us ensure that the item doesn't already exist in the options array
                if (!!item && !!item.newOption) {
                    self.state.options.unshift({label: item.label, value: item.value});
                    self.setState({options: self.state.options}, callback);
                }
            }}>
        </SimpleSelect>
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function(){
        return {
            options: ["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
                return {label: fruit, value: fruit}
            })
        }
    }
    
});

React.render(<Form/>, mountNode)
"""
        ls: """
Form = React.create-class do 
    
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
            on-value-change: ({label, value, new-option}?, callback) !~>
                # here, we add the selected item to the options array, the "new-option"
                # property, added to items created by the "create-from-search" function above, 
                # helps us ensure that the item doesn't already exist in the options array
                if !!new-option
                    @set-state options: [{label, value}] ++ @state.options, callback 
                
    get-initial-state: ->
        options: <[apple mango grapes melon strawberry]> |> map ~> label: it, value: it
                
React.render (React.create-element Form, null), mount-node
"""
    * title: "Event listeners"
      description: ""
      languages:
        jsx: """
Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        self = this;
        models = !!this.state.make ? this.state.models[this.state.make.label] : [];
        return <div>
            
            <SimpleSelect
                placeholder = "Select a make"
                options = {this.state.makes.map(function(make){
                    return {label:make, value: make};
                })}
                value = {this.state.make}
                
                // onValueChange :: Item -> (a -> Void) -> Void
                onValueChange = {function(make, callback) {
                    self.setState ({make: make, model: undefined}, function(){
                        self.refs.models.focus();
                        callback();
                    });
                }}
                
                // onFocus :: Item -> String -> Void
                onFocus = {function(item, reason){
                    self.setState({focused: true});
                }}
                
                // onBlur :: Item -> String -> Void
                onBlur = {function(item, reason){
                    self.setState({focused: false});
                }}
                
                style = {this.state.focused ? {color: "#0099ff"} : {}}/>
            
            <SimpleSelect
                ref = "models"
                placeholder = "Select a model"
                options = {models.map(function(model){
                    return {label: model, value: model};
                })}
                value = {this.state.model}
                
                // disabled :: Boolean
                disabled = {typeof this.state.make == "undefined"}
                
                onValueChange = {function(model, callback) {
                    self.setState({model: model}, callback);
                }}
                style = {{
                    marginTop: 20,
                    opacity: !!this.state.make ? 1 : 0.5
                }}/>
                
        </div>
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function(){
        return {
            focused: false,
            make: undefined,
            makes: ["Bentley", "Cadillac", "Lamborghini", "Maserati", "Volkswagen"],
            model: undefined,
            models: {
                Bentley: ["Arnage", "Azure", "Continental", "Corniche", "Turbo R"],
                Cadillac: ["Allante", "Catera", "Eldorado", "Fleetwood", "Seville"],
                Lamborghini: ["Aventador", "Countach", "Diablo", "Gallardo", "Murcielago"],
                Maserati: ["Bitturbo", "Coupe", "GranTurismo", "Quattroporte", "Spyder"],
                Volkswagen: ["Beetle", "Fox", "Jetta", "Passat", "Rabbit"]
            }
        }
    }
    
});

React.render(<Form/>, mountNode);
"""
        ls: """
Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        div null,
        
            # MAKES
            React.create-element SimpleSelect,
                placeholder: "Select a make"
                options: @state.makes |> map ~> label: it, value: it
                value: @state.make
                
                # on-value-change :: Item -> (a -> Void) -> Void
                on-value-change: (make, callback) !~> 
                    <~ @set-state {make, model: undefined}
                    @refs.models.focus!
                    callback!
                
                # on-focus :: Item -> String -> Void
                on-focus: (item, reason) ~>
                    @set-state focused: true
                
                # on-blur :: Item -> String -> Void
                on-blur: (item, reason) !~>
                    @set-state focused:false
                    
                style: if @state.focused then color: "#0099ff" else {}
                    
            # MODELS
            React.create-element SimpleSelect,
                ref: \\models
                placeholder: "Select a model"
                options: (@state.models?[@state?.make?.label] ? []) |> map ~> label: it, value: it
                value: @state.model
                
                # disabled :: Boolean
                disabled: typeof @state.make == \\undefined
                
                on-value-change: (model, callback) ~> @set-state {model}, callback
                style: margin-top: 20, opacity: if !!@state.make then 1 else 0.5
                    
    # get-initial-state :: a -> UIState
    get-initial-state: -> 
        focused: false
        make: undefined
        makes: ["Bentley", "Cadillac", "Lamborghini", "Maserati", "Volkswagen"]
        model: undefined
        models: 
            Bentley: ["Arnage", "Azure", "Continental", "Corniche", "Turbo R"]
            Cadillac: ["Allante", "Catera", "Eldorado", "Fleetwood", "Seville"]
            Lamborghini: ["Aventador", "Countach", "Diablo", "Gallardo", "Murcielago"]
            Maserati: ["Bitturbo", "Coupe", "GranTurismo", "Quattroporte", "Spyder"]
            Volkswagen: ["Beetle", "Fox", "Jetta", "Passat", "Rabbit"]
              
    
React.render (React.create-element Form, null), mount-node
"""
    * title: "Custom option & value rendering"
      description: ""
      languages:
        jsx: """
Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <SimpleSelect 
            options={this.state.options} 
            placeholder="Select a color"
            createFromSearch={function(options, search){
                if (search.length == 0 || (options.map(function(option){
                    return option.label;
                })).indexOf(search) > -1)
                    return null;
                else
                    return {label: search, value: search};
            }}
            onValueChange={function(item, callback){
                if (!!item && !!item.newOption) {
                    self.state.options.unshift({label: item.label, value: item.value});
                    self.setState({options: self.state.options}, callback);
                }
            }}
        
            // renderOption :: Int -> Item -> ReactElement
            renderOption={function(index, item){
                return <div className="simple-option" style={{display: "flex", alignItems: "center"}}>
                    <div style={{
                        backgroundColor: item.label, borderRadius: "50%", width: 24, height: 24
                    }}></div>
                    <div style={{marginLeft: 10}}>
                        {!!item.newOption ? "Add " + item.label + " ..." : item.label}
                    </div>
                </div>
            }}
            
            // renderValue :: Int -> Item -> ReactElement
            renderValue={function(index, item){
                return <div className="simple-value">
                    <span style={{
                        backgroundColor: item.label, borderRadius: "50%", 
                        verticalAlign: "middle", width: 24, height: 24
                    }}></span>
                    <span style={{marginLeft: 10, verticalAlign: "middle"}}>{item.label}</span>
                </div>
            }}>
        </SimpleSelect>
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function(){
        
        // randomColor :: a -> String
        function randomColor() {
            var color = [0,0,0].map(function(){
                return Math.floor(Math.random() * 255);
            });
            color.push(Math.floor(Math.random() * 10) / 10);
            return "rgba(" + color.join(",") + ")"
        }
        
        options = [];
        for (var i = 0; i < 10; i++) {
            color = randomColor();
            options.push({label: color, value: color});
        }
        return {options: options};
    }
    
});

React.render(<Form/>, mountNode)
"""
        ls: """
Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        React.create-element SimpleSelect,
            options: @state.options
            placeholder: "Select a color"
            create-from-search: (options, search) ~> 
                return null if search.length == 0 or search in map (.label), options
                label: search, value: search
            on-value-change: ({label, value, new-option}?, callback) !~>
                if !!new-option
                    @set-state options: [{label, value}] ++ @state.options, callback 
            
            # render-option :: Int -> Item -> ReactElement
            render-option: (index, {label, new-option}?) ~>
                div do 
                    class-name: \\simple-option
                    style: display: \\flex, align-items: \\center
                    div style: background-color: label, width: 24, height: 24, border-radius: \\50%
                    div style: margin-left: 10, if !!new-option then "Add \#\{label\}..." else label
            
            # render-value :: Int -> Item -> ReactElement
            render-value: (index, {label}) ~>
                div do 
                    class-name: \\simple-value
                    style: display: \\inline-block
                    span style: 
                        background-color: label, border-radius: \\50%, 
                        vertical-align: \\middle, width: 24, height: 24
                    span style: margin-left: 10, vertical-align: \\middle, label
                
    get-initial-state: ->
        
        # random-color :: a -> String
        random-color = -> 
            [0 to 2] 
            |> map -> Math.floor Math.random! * 255
            |> -> it ++ (Math.round Math.random! * 10) / 10
            |> Str.join \\,
            |> -> "rgba(\#\{it\})"
            
        options: [0 til 10] |> map -> 
            color = random-color!
            label: color, value: color
                
React.render (React.create-element Form, null), mount-node
"""
    * title: "Remote options"
      description: ""
      languages:
        jsx: """
Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <SimpleSelect 
            placeholder = "Select a library"
            options = {this.state.libraries}
            search = {this.state.search}
            
            // onSearchChange :: String -> (a -> Void) -> Void
            onSearchChange={function(search, callback){
                self.setState({search: search}, callback);
                if (search.length == 0)
                    return;
                if (!!self.req)
                    self.req.abort();
                url = "http://api.cdnjs.com/libraries?fields=version,homepage&search=" + search;
                self.req = $.getJSON(url).done(function(result){
                    self.setState({libraries: take(50, result.results)})
                });
            }}
            
            // filterOptions :: [Item] -> Item -> String -> [Item]
            filterOptions = {function(options, value, search){
                return options;
            }}
            
            renderOption = {function(index, item){
                return <div className="simple-option" style={{fontSize: 12}}>
                    <div> 
                        <span style={{fontWeight: "bold"}}>{item.name}</span>
                        <span>{"@" + item.version}</span>
                    </div>
                    <div>
                        <a href={{href: item.homepage, target: "blank"}}>{item.homepage}</a>
                    </div>
                </div>
            }}
            
            renderValue = {function(index, item){
                return <div className="simple-value">
                    <span style={{fontWeight: "bold"}}>{item.name}</span>
                    <span>{"@" + item.version}</span>
                </div>
            }}
            
            // render-no-results-found :: a -> ReactElement
            renderNoResultsFound = {function(){
                return <div className="no-results-found" style={{fontSize: 13}}>
                    {typeof self.req == "undefined" && self.state.search.length == 0 ? 
                    "type a few characters to kick off remote search":"No results found"}
                </div>
            }}/>
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function(){
        return {
            libraries: [],
            search: ""
        }
    }
    
});

React.render(<Form/>, mountNode)
"""
        ls: """
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
                @req = $.getJSON "http://api.cdnjs.com/libraries?fields=version,homepage&search=\#\{search\}"
                    ..done ({results}) ~>
                        @set-state libraries: take 50, (results ? [])
                        delete @req
            
            # filter-options :: [Item] -> Item -> String -> [Item]
            filter-options: (options, value, search) -> options
            
            render-option: (index, {name, latest, version, homepage}) ~>
                div class-name: \\simple-option, style: font-size: 12,
                    div null,
                        span style: font-weight: \\bold, name
                        span null, "@\#\{version\}"
                    div null, 
                        a {href: homepage, target: \\blank}, homepage
                        
            render-value: (index, {name, version}) ~>
                div class-name: \\simple-value,
                    span style: font-weight: \\bold, name
                    span null, "@\#\{version\}"
                     
            # render-no-results-found :: a -> ReactElement
            render-no-results-found: ~>
                div class-name: \\no-results-found, style: font-size: 13,
                    if typeof @req == \\undefined and @state.search.length == 0
                        "type a few characters to kick off remote search"
                    else
                        "No results found"
                        
    get-initial-state: ->
        libraries: []
        search: ""
                
React.render (React.create-element Form, null), mount-node
"""
    ...

App = React.create-class do

    render: -> 
        div class-name: \app,
            div class-name: \title, 'React Selectize'
            div class-name: \examples,
                examples |> map ({title, description, {jsx, ls}:languages}) ~>
                    Example do 
                        title: title
                        description: description
                        width: 850
                        style: margin-top: 100
                        initial-language: \livescript
                        languages: 
                            * id: \livescript
                              name: "Livescript"
                              initial-content: ls
                              on-execute: (content, mount-node) -> eval compile content, {bare: true}
                            * id: \jsx
                              name: "JSX"
                              initial-content: jsx
                              on-execute: (content, mount-node) -> eval react-tools.transform content
                            * id: \javascript
                              name: "JS"
                              initial-content: react-tools.transform jsx
                              on-execute: (content, mount-node) -> eval content
                        

React.render (React.create-element App, null), document.body