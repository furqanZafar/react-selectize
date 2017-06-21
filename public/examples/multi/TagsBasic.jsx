Form = createReactClass({
    
    // render :: a -> ReactElement
    render: function(){
        self = this;
        return <MultiSelect
            
            // createFromSearch :: [Item] -> [Item] -> String -> Item?
            createFromSearch = {function(options, values, search){
                labels = values.map(function(value){ 
                    return value.label; 
                })
                if (search.trim().length == 0 || labels.indexOf(search.trim()) != -1) 
                    return null;
                return {label: search.trim(), value: search.trim()};
            }}
            
        />;
    },
    
});

render(<Form/>, mountNode); 