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