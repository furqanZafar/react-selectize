Form = createReactClass({
    
    // render :: a -> ReactElement
    render: function(){
        options = ["apple", "mango", "grapes", "melon", "strawberry"].map(function(fruit){
            return {label: fruit, value: fruit}
        });
        return <MultiSelect 
            options = {options} 
            placeholder = "Select fruits" 
            ref = "select"
            dropdownDirection = {this.state.dropdownDirection}
        />
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function(){
        return {dropdownDirection: 1}
    },

    // componentDidMount :: a -> Void
    componentDidMount: function() {
        self = this;
        this.onScrollChange = function(){
            if (typeof self.refs.select == "undefined")
                return;
            var screenTop = self.refs.select.getDOMNode().offsetTop - (window.scrollY || document.documentElement.scrollTop);
            dropdownDirection = (window.innerHeight - screenTop) < 215 ? -1 : 1
            if (self.state.dropdownDirection != dropdownDirection)
                self.setState({dropdownDirection: dropdownDirection});
        };
        window.addEventListener("scroll", this.onScrollChange);
    },

    // componentWillUnmount :: a -> Void
    componentWillUnmount: function(){
        window.removeEventListener("scroll", this.onScrollChange);
    }

});

render(<Form/>, mountNode)