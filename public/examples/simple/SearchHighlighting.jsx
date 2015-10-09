// partitionString = require("prelude-extension").partitionString
// ReactSelectize = require("react-selectize")
// HighlightedText = ReactSelectize.HighlightedText
// SimpleSelect = ReactSelectize.SimpleSelect

Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var self = this;
        return <SimpleSelect
            placeholder = "Select a fruit"

            // we use state for search, so we can access it inside the options map function below
            search = {this.state.search}
            onSearchChange = {function(search, callback){
                self.setState({search: search}, callback);
            }}

            // the partitionString method from prelude-extension library has the following signature:
            // parititionString :: String -> String -> [[Int, Int, Boolean]]
            options = {["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
                return {
                    label: fruit,
                    value: fruit,
                    labelPartitions: partitionString(fruit, self.state.search)
                };
            })}

            // we add the search to the uid property of each option
            // to re-render it whenever the search changes
            // uid :: (Equatable e) => Item -> e
            uid = {function(item){
                return item.value + self.state.search;
            }}

            // here we use the HighlightedText component to render the result of partition-string
            // render-option :: Item -> ReactElement
            renderOption = {function(item){
                return <div className = "simple-option">
                    <HighlightedText
                        partitions = {item.labelPartitions}
                        text = {item.label}
                        highlightStyle = {{
                            backgroundColor: "rgba(255,255,0,0.4)",
                            fontWeight: "bold"
                        }}
                    />
                </div>
            }}
        />
    },

    // getInitialState :: a -> UIState
    getInitialState: function() {
        return {search: ""}
    }
    
});

render(<Form/>, mountNode)