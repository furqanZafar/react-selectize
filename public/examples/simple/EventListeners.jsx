Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        self = this;
        models = !!this.state.make ? this.state.models[this.state.make.label] : [];
        return <div>
            
            <SimpleSelect
                placeholder = "Select a make"
                options = {this.state.makes.map(function(make){
                    return {label:make, value: make};
                })}
                value = {this.state.make}
                
                // onValueChange :: Item -> (a -> Void) -> Void
                onValueChange = {function(make, callback) {
                    self.setState ({make: make, model: undefined}, function(){
                        self.refs.models.focus();
                        callback();
                    });
                }}
                
                // onFocus :: Item -> String -> Void
                onFocus = {function(item, reason){
                    self.setState({focused: true});
                }}
                
                // onBlur :: Item -> String -> Void
                onBlur = {function(item, reason){
                    self.setState({focused: false});
                }}
                
                style = {this.state.focused ? {color: "#0099ff"} : {}}/>
            
            <SimpleSelect
                ref = "models"
                placeholder = "Select a model"
                options = {models.map(function(model){
                    return {label: model, value: model};
                })}
                value = {this.state.model}
                
                // disabled :: Boolean
                disabled = {typeof this.state.make == "undefined"}
                
                onValueChange = {function(model, callback) {
                    self.setState({model: model}, callback);
                }}
                style = {{
                    marginTop: 20,
                    opacity: !!this.state.make ? 1 : 0.5
                }}/>
                
        </div>
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function(){
        return {
            focused: false,
            make: undefined,
            makes: ["Bentley", "Cadillac", "Lamborghini", "Maserati", "Volkswagen"],
            model: undefined,
            models: {
                Bentley: ["Arnage", "Azure", "Continental", "Corniche", "Turbo R"],
                Cadillac: ["Allante", "Catera", "Eldorado", "Fleetwood", "Seville"],
                Lamborghini: ["Aventador", "Countach", "Diablo", "Gallardo", "Murcielago"],
                Maserati: ["Bitturbo", "Coupe", "GranTurismo", "Quattroporte", "Spyder"],
                Volkswagen: ["Beetle", "Fox", "Jetta", "Passat", "Rabbit"]
            }
        }
    }
    
});

React.render(<Form/>, mountNode);