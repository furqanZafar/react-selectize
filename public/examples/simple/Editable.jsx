Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this, 
            options = ["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
                return {label: fruit, value: fruit}
            });
        return <SimpleSelect 
            placeholder = "Select a fruit"
            options = {options} 

            // editable :: Item -> String
            editable = {function(item){
                return item.label;
            }}
        />
    }
    
});

render(<Form/>, mountNode)