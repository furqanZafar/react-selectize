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