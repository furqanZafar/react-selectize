Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        self = this;
        return <MultiSelect
            placeholder = "Select youtube channels"

            // set anchor to undefined, to lock the cursor at the start
            // anchor :: Item
            anchor = {this.state.anchor} 

            options = {this.state.channels}
            values = {this.state.selectedChannels}
            onValuesChange = {function(selectedChannels, callback){
                // lock the cursor at the end
                self.setState({
                    anchor: _.last(selectedChannels), 
                    selectedChannels: selectedChannels
                }, callback);
            }}
        />;
    },
    
    //getInitialState :: a -> UIState
    getInitialState: function(){
        channels = [
            "Dude perfect", 
            "In a nutshell", 
            "Smarter everyday", 
            "Vsauce", 
            "Veratasium"
        ].map(function(str){
            return {label: str, value: str};
        });
        return {
            anchor: _.last(channels),
            channels: channels,
            selectedChannels: [_.last(channels)]
        };
    }
});

React.render(<Form/>, mountNode); 