Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <div>

            <SimpleSelect 
                placeholder = "Select a fruit" 
                ref = "select"

                // default value support
                defaultValue = {{label: "melon", value: "melon"}}

                // on change callback
                onValueChange = {function(value, callback){
                    console.log("you selected: " + JSON.stringify(value, null, 4));
                    callback();
                }}

                // form serialization
                name = "fruit"
                serialize = {function(item){
                    return !!item ? item.value : undefined
                }} // <- optional in this case, default implementation
            >
                <option key = "apple" value = "apple">apple</option>
                <option key = "mango" value = "mango">mango</option>
                <option key = "grapes" value = "grapes">grapes</option>
                <option key = "melon" value = "melon">melon</option>
                <option key = "strawberry" value = "strawberry">strawberry</option>
            </SimpleSelect>

            <input 
                type = "submit"
                onClick = {function(){
                    alert ("you selected: " + JSON.stringify(self.refs.select.value(), null, 4));
                }}
                style = {{
                    cursor: "pointer",
                    height: 24,
                    marginTop: 10
                }}
            />

        </div>

    }
    
});

render(<Form/>, mountNode)