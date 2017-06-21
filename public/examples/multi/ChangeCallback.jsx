Form = createReactClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <div>
            {function(){
                if (self.state.selectedCountries.length > 0)
                    return <div style = {{margin: 8}}>
                        <span>you selected: </span>
                        <span style = {{fontWeight: "bold"}}>
                            {self.state.selectedCountries.map(function(selectedCountry){
                                return selectedCountry.label;
                            }).join(", ")}
                        </span>
                    </div>
            }()}
            <MultiSelect
                ref = "select"
                placeholder = "Select countries"
                options = {this.state.countries}
                value = {this.state.selectedCountries}

                // onValueChange :: Item -> (a -> Void) -> void
                onValuesChange = {function(selectedCountries){
                    self.setState({selectedCountries: selectedCountries});
                }}

                // renderNoResultsFound :: a -> ReactElement
                renderNoResultsFound = {function() {
                    return <div className = "no-results-found">
                        {!!self.req ? "loading countries ..." : "No results found"}
                    </div>
                }}
            />
        </div>
    },

    // getInitialState :: a -> UIState
    getInitialState: function(){
        return {
            countries: [],
            selectedCountries: []
        };
    },

    // component-will-mount :: a -> Void
    componentWillMount: function(){
        var self = this;
        this.req = $.getJSON("http://restverse.com/countries").done(function(countries){
            self.setState({countries: countries}, function(){
                self.refs.select.highlightFirstSelectableOption();
            });
        }).always(function(){
            delete self.req;
        });
    }
    
});

render(<Form/>, mountNode)