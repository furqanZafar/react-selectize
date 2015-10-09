Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <SimpleSelect 
            options={this.state.options} 
            placeholder="Select a color"
            createFromSearch={function(options, search){
                if (search.length == 0 || (options.map(function(option){
                    return option.label;
                })).indexOf(search) > -1)
                    return null;
                else
                    return {label: search, value: search};
            }}
            onValueChange={function(item, callback){
                if (!!item && !!item.newOption) {
                    self.state.options.unshift({label: item.label, value: item.value});
                    self.setState({options: self.state.options}, callback);
                } else
                    callback();
            }}
        
            // renderOption :: Int -> Item -> ReactElement
            renderOption={function(item){
                return <div className="simple-option" style={{display: "flex", alignItems: "center"}}>
                    <div style={{
                        backgroundColor: item.label, borderRadius: "50%", width: 24, height: 24
                    }}></div>
                    <div style={{marginLeft: 10}}>
                        {!!item.newOption ? "Add " + item.label + " ..." : item.label}
                    </div>
                </div>
            }}
            
            // renderValue :: Int -> Item -> ReactElement
            renderValue={function(item){
                return <div className="simple-value">
                    <span style={{
                        backgroundColor: item.label, borderRadius: "50%", 
                        verticalAlign: "middle", width: 24, height: 24
                    }}></span>
                    <span style={{marginLeft: 10, verticalAlign: "middle"}}>{item.label}</span>
                </div>
            }}>
        </SimpleSelect>
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function(){
        
        // randomColor :: a -> String
        function randomColor() {
            var color = [0,0,0].map(function(){
                return Math.floor(Math.random() * 255);
            });
            color.push(Math.floor(Math.random() * 10) / 10);
            return "rgba(" + color.join(",") + ")"
        }
        
        options = [];
        for (var i = 0; i < 10; i++) {
            color = randomColor();
            options.push({label: color, value: color});
        }
        return {options: options};
    }
    
});

render(<Form/>, mountNode)