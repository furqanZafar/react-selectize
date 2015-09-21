// SimpleSelect = require("react-selectize").SimpleSelect

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