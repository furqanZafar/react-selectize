Form = React.createClass({
    
    // render :: a -> ReactElement
    render: function(){
        var groups = [{
                groupId: "asia",
                title: "Asia"
            }, {
                groupId: "africa",
                title: "Africa"
            }, {
                groupId: "europe",
                title: "Europe"
            }],
            countries = [
                ["asia", "china"],
                ["asia", "korea"],
                ["asia", "japan"],
                ["africa", "nigeria"],
                ["africa", "congo"],
                ["africa", "zimbabwe"],
                ["europe", "germany"],
                ["europe", "poland"],
                ["europe", "spain"],
            ];
        return <MultiSelect
            groups = {groups}
            //groupsAsColumns = {true}
            options = {countries.map(function(item){
                return {
                    groupId: item[0],
                    label: item[1],
                    value: item[1]
                };
            })}
            placeholder = "Select countries"
        />;
    }
    
});

render(<Form/>, mountNode)