Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this, 
            options = ["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
                return {label: fruit, value: fruit}
            });
        return <MultiSelect placeholder="Select 2 fruits" options={options} maxValues={2}/>
    }
    
});

render(<Form/>, mountNode)