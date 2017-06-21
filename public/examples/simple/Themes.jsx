// SimpleSelect = require("react-selectize").SimpleSelect

Form = createReactClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this, 
            options = ["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
                return {label: fruit, value: fruit}
            });
        return <SimpleSelect 
            options = {options} 
            placeholder = "Select a fruit"
            theme = "material" // can be one of "default" | "bootstrap3" | "material" | ...
            transitionEnter = {true}
        />
    }
    
});

render(<Form/>, mountNode)