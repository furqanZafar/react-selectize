Form = createReactClass({
    
    // render :: () -> ReactElement
    render: function(){
        self = this;
        return <MultiSelect
            placeholder = "Select youtube channels"

            // set anchor to undefined, to lock the cursor at the start
            // anchor :: Item
            anchor = {this.state.anchor} 

            options = {this.state.channels}
            values = {this.state.selectedChannels}
            onValuesChange = {function(selectedChannels){

                // lock the cursor at the end
                self.setState({
                    anchor: _.last(selectedChannels), 
                    selectedChannels: selectedChannels
                });

            }}
        />;
    },
    
    //getInitialState :: () -> UIState
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

render(<Form/>, mountNode); 