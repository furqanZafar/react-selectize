Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        self = this;
        return <MultiSelect
            
            values = {this.state.tags}
            
            // delimtiers :: [KeyCode]
            delimiters = {[188]}

            // valuesFromPaste :: [Item] -> [Item] -> String -> [Item]
            valuesFromPaste = {function(options, values, pastedText){
                return pastedText
                    .split(",")
                    .filter(function(text){
                        var labels = values.map(function(item){
                            return item.label;
                        })
                        return labels.indexOf(text) == -1;
                    })
                    .map(function(text){
                        return {label: text, value: text};
                    });
            }}

            // restoreOnBackspace :: Item -> String
            restoreOnBackspace = {function(item){
                return item.label;
            }}

            // onValuesChange :: [Item] -> (a -> Void) -> Void
            onValuesChange = {function(tags){
                self.setState({tags: tags});
            }}
            
            // createFromSearch :: [Item] -> [Item] -> String -> Item?
            createFromSearch = {function(options, values, search){
                labels = values.map(function(value){ 
                    return value.label; 
                })
                if (search.trim().length == 0 || labels.indexOf(search.trim()) != -1) 
                    return null;
                return {label: search.trim(), value: search.trim()};
            }}
            
            // renderNoResultsFound :: [Item] -> String -> ReactElement
            renderNoResultsFound = {function(values, search) {
                return <div className = "no-results-found">
                    {function(){
                        if (search.trim().length == 0)
                            return "Type a few characters to create a tag";
                        else if (values.map(function(item){ return item.label; }).indexOf(search.trim()) != -1)
                            return "Tag already exists";
                    }()}
                </div>
            }}
        />;
    },
    
    //getInitialState :: a -> UIState
    getInitialState: function(){
        return {tags: ["react", "d3"].map(function(str){
            return {label: str, value: str};
        })};
    }
        
});

render(<Form/>, mountNode); 