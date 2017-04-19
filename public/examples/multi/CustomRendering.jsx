Form = createReactClass({
    
    // render :: a -> ReactElement
    render: function() {
        self = this;
        return <MultiSelect
            placeholder = "Select 5 emojis"
            options = {this.state.emojis}
            values = {this.state.selectedEmojis}
            maxValues = {5}
            
            // restoreOnBackspace :: Item -> String
            restoreOnBackspace = {function(item){
                return item.label;
            }}
            
            // onValuesChange :: [Item] -> (a -> Void) -> Void
            onValuesChange = {function(selectedEmojis){
                self.setState({
                    selectedEmojis: selectedEmojis
                });
            }}
            
            // filterOptions :: [Item] -> [Item] -> String -> [Item]
            filterOptions = {function(options, values, search){
                charMap = {
                    ':)' : 'smile', ':(' : 'frowning', ':D' : 'grin',
                    ':((' : 'disappointed', ':P' : 'stuck_out_tongue', ';)' : 'wink',
                    '<3' : 'heart', 'o.O' : 'confused', ':o' : 'open_mouth',
                    ':*' : 'kissing', 'B|' : 'sunglasses'
                };
                if (!!charMap[search])
                    return options.filter(function(option){
                        return option.label == charMap[search];
                    });
                else
                    return _.chain(options)
                        .reject(function(option){
                            return self.state.selectedEmojis.map(function(emoji){
                                return emoji.value
                            }).indexOf(option.value) > -1
                        })
                        .filter(function(option){
                            return option.label.indexOf(search) == 0;
                        })
                        .first(100)
                        .value();
            }}

            // uid :: (Eq e) => Item -> e
            uid = {function(item){
                return item.label;
            }}

            // renderOption :: Int -> Item -> ReactElement
            renderOption = {function(item){
                return <div className = "simple-option">
                    <img src = {item.value} style = {{marginRight: 4, verticalAlign: "middle", width: 24}}/>
                    <span>{item.label}</span>
                </div>
            }}
            
            // renderValue :: Int -> Item -> ReactElement
            renderValue = {function(item){
                return <div className = "removable-emoji">
                    <span onClick = {function(){
                        self.setState({
                            selectedEmojis: _.reject(self.state.selectedEmojis, function(emoji){
                                return emoji.value == item.value;
                            }) 
                        });
                    }}>x</span>
                    <img src = {item.value} style = {{marginRight: 4, verticalAlign: "middle", width: 24}}/>
                </div>
            }}
        />
    },
    
    // getInitialState :: a -> UIState
    getInitialState: function() {
        return {emojis: [], selectedEmojis: []}
    },
    
    // componentWillMount :: a -> Void
    componentWillMount: function() {
        self = this;
        $.getJSON("http://api.github.com/emojis").done(function(result){
            self.setState({
                emojis: _.chain(result)
                    .pairs()
                    .map(function(arr){
                        return {label: arr[0], value: arr[1]};
                    })
                    .value()
            });    
        });
    }
    
});

render(<Form/>, mountNode);