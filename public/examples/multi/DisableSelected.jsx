// MultiSelect = require("react-selectize").MultiSelect

Form = createReactClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this, 
            options = ["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
                return {label: fruit, value: fruit}
            });
        return <MultiSelect 
            placeholder = "Select fruits"
            options = {options} 
            
            // filterOptions :: [Item] -> [Item] -> String -> [Item]
            filterOptions = {function(options, values, search){
                return _.chain(options)
                    .filter(function(option){
                        return option.label.indexOf(search) > -1;
                    })
                    .map(function(option){
                        option.selectable = values.map(function(item){
                            return item.value;
                        }).indexOf(option.value) == -1
                        return option;
                    })
                    .value()
            }}
        />
    }
    
});

render(<Form/>, mountNode)