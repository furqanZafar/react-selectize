Form = React.create-class do 
    
    # render :: a -> ReactElement
    render: ->
        groups = 
            * group-id: \asia
              title: \Asia
            * group-id: \africa
              title: \Africa
            * group-id: \europe
              title: \Europe
        countries = 
            * <[asia china]>
            * <[asia korea]>
            * <[asia japan]>
            * <[africa nigeria]>
            * <[africa congo]>
            * <[africa zimbabwe]>
            * <[europe germany]>
            * <[europe poland]>
            * <[europe spain]>
        React.create-element MultiSelect,
            groups: groups 
            #groups-as-columns: true
            options: countries |> map ([group-id, label]) ~> {group-id, label, value: label}
            placeholder: "Select countries"
                
React.render (React.create-element Form, null), mount-node