Form = createReactClass({
    
    // render :: a -> ReactElement
    render: function(){
        return <SimpleSelect
            placeholder = "Select an iPhone model"
            options = {this.state.models}
            
            // renderOption :: Int -> Item -> ReactElement
            renderOption = {function(item){
                optionStyle = item.selectable ? {} : {
                    backgroundColor: "\#f8f8f8",
                    color: "\#999",
                    cursor: "default",
                    fontStyle: "oblique",
                    textShadow: "0px 1px 0px white"
                },
                outOfStock = item.selectable ? undefined : <span style={{
                    color: "\#c5695c",
                    float: "right",
                    fontSize: 12
                }}>(out of stock)</span>;
                return <div className="simple-option" style={optionStyle}>
                    <span>{item.label}</span>
                    {outOfStock}
                </div>
            }}
        />
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function(){
        return {
            models: [16, 64, 128].reduce(function(memo, size){
                return memo.concat(["Space Grey", "Silver", "Gold"].map(function(color){
                    label = size + "GB " + color;
                    return {label: label, value: label, selectable: Math.random() > 0.5}
                }))
            }, [])
        }
    }
    
});

render(<Form/>, mountNode)