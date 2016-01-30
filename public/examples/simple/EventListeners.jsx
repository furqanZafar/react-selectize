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
                
                // onValueChange :: Item -> ()
                onValueChange = {function(make) {
                    self.setState ({make: make, model: undefined}, function(){
                        self.refs.models.focus();
                    });
                }}
                
                // onFocus :: Item -> String -> ()
                onFocus = {function(item, reason){
                    self.setState({focused: true});
                }}
                
                // onBlur :: Item -> String -> ()
                onBlur = {function(item, reason){
                    self.setState({focused: false});
                }}
                
                // onEnter :: Item -> ()
                onEnter = {function(item){
                    if (typeof item == "undefined")
                        alert("you did not select any item");
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
                
                onValueChange = {function(model) {
                    self.setState({model: model});
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

render(<Form/>, mountNode);