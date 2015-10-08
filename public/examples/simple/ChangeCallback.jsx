Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <div>
            <SimpleSelect
                ref = "select"
                placeholder = "Select a country"
                options = {this.state.countries}
                value = {this.state.country}

                // onValueChange :: Item -> (a -> Void) -> void
                onValueChange = {function(country, callback){
                    self.setState({country: country}, callback);
                }}

                // renderNoResultsFound :: a -> ReactElement
                renderNoResultsFound = {function() {
                    return <div className = "no-results-found">
                        {!!self.req ? "loading countries ..." : "No results found"}
                    </div>
                }}
            />
            {function(){
                if (!!self.state.country)
                    return <div style = {{margin: 8}}>
                        <span>you selected: </span>
                        <span style = {{fontWeight: "bold"}}>{self.state.country.label}</span>
                    </div>
            }()}
        </div>
    },

    // getInitialState :: a -> UIState
    getInitialState: function(){
        return {
            countries: [],
            country: undefined
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

React.render(<Form/>, mountNode)