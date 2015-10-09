Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <div>

            <SimpleSelect 
                placeholder = "Select a fruit" 
                ref = "select"
                onValueChange = {function(value, callback){
                    alert("you selected: " + JSON.stringify(value, null, 4));
                    callback();
                }}>
                <option key = "apple" value = "apple">apple</option>
                <option key = "mango" value = "mango">mango</option>
                <option key = "grapes" value = "grapes">grapes</option>
                <option key = "melon" value = "melon">melon</option>
                <option key = "strawberry" value = "strawberry">strawberry</option>
            </SimpleSelect>

            <button 
                onClick = {function(){
                    alert ("you selected: " + JSON.stringify(self.refs.select.value(), null, 4));
                }}
                style = {{
                    cursor: "pointer",
                    height: 24,
                    marginTop: 10
                }}>
                Get current value
            </button>

        </div>

    }
    
});

render(<Form/>, mountNode)