# API Reference

### SimpleSelect props

|    Property                |   Type                              |   Description                  |
|----------------------------|-------------------------------------|--------------------------------|
|    autosize                | InputElement -> Int                 | `function($search){return $search.value.length * 10}` custom logic for autosizing the input element|
|    className               | String                              | class name for the outer element, in addition to "simple-select"|
|    createFromSearch        | [Item] -> String -> Item?           | implement this function to create new items on the fly, `function(options, search){return {label: search, value: search}}`, return null to avoid option creation for the given parameters|
|    defaultValue            | Item                                | similar to the defaultValue prop of React.DOM.Select |
|    delimiters              | [KeyCode]                           | a collection of character keycodes that when pressed confirm selection of the highlighted item |
|    disabled                | Boolean                             | disables interaction with the Select control|
|    dropdownDirection       | Int                                 | defaults to 1, setting it to -1 opens the dropdown upward|
|    editable                | Boolean                             | defaults to false, setting it to true makes the selected option editable|
|    filterOptions           | [Item]-> String -> [Item]           | implement this function for custom synchronous filtering logic, `function(options, search) {return options}`|
|    groupId                 | Item -> b                           | `function(item){return item.groupId}` this function is used to identify which group an option belongs to, it must return a value that matches the groupId property of an object in the groups collection|
|    groups                  | [Group]                             | collection of objects where each object must atleast have a groupId property|
|    groupsAsColumns         | Boolean                             | display option groups in columns|
|    onBlur                  | Item -> String -> Void              | `function(value, reason){}` reason can be either "click" (loss of focus because the user clicked elsewhere), "tab" or "blur" (invoked refs.simpleSelect.blur())|
|    onEnter                 | Item -> Void                        | `function(highlightedOption){}` fired with the (highlightedOption or undefined) when the user hits the return key|
|    onFocus                 | Item -> String -> Void              | `function(value, reason){}` reason can be either "event" (when the control gains focus outside) or "focus" (when the user invokes refs.simpleSelect.focus())|
|    onSearchChange          | String -> (a -> Void) -> Void       | `function(search, callback){self.setState({search: search}, callback);}` or `function(search,callback){callback();}` i.e. callback MUST always be invoked|
|    onValueChange           | Item -> (a -> Void) -> Void         | `function(selectedValue, callback){self.setState({selectedValue: selectedValue}, callback)}` or `function(value, callback){callback()}` i.e. callback MUST always be invoked|
|    options                 | [Item]                              | list of items by default each option object MUST have label & value property, otherwise you must implement the render* & filterOptions methods|
|    placeholder             | String                              | displayed when there is no value|
|    renderNoResultsFound    | Item -> String -> ReactElement      | `function(item, search){return React.DOM.div(null);}` returns a custom way for rendering the "No results found" error|
|    renderGroupTitle        | Int -> Group -> ReactElement        | `function(index, group){return React.DOM.div(null)}` returns a custom way for rendering the group title|
|    renderOption            | Item -> ReactElement                | `function(item){return React.DOM.div(null);}` returns a custom way for rendering each option|
|    renderValue             | Item -> ReactElement                | `function(item){return React.DOM.div(null);}` returns a custom way for rendering the selected value|
|    restoreOnBackspace      | Item -> String                      | `function(item){return item.label;}` implement this method if you want to go back to editing the item when the user hits the [backspace] key instead of getting removed|
|    search                  | String                              | the text displayed in the search box|
|    style                   | Object                              | the CSS styles for the outer element|
|    transitionEnter         | Boolean                             | defaults to false, setting this to true animates the opening of the dropdown using the `slide-*` css classes|
|    transitionEnterTimeout  | Number                              | duration specified in milliseconds, it must match the transition duration specified under the CSS class `.slide-enter-active` |
|    transitionLeave         | Boolean                             | defaults to false, setting this to true animates the closing of the dropdown using the `slide-*` css classes|
|    transitionLeaveTimeout  | Number                              | duration specified in milliseconds, it must match the transition duration specified under the CSS class `.slide-leave-active` |
|    uid                     | (Eq e) => Item -> e                 | `function(item){return item.value}` returns a unique id for a given option, defaults to the value property|
|    value                   | Item                                | the selected value, i.e. one of the objects in the options array|

### SimpleSelect methods

|    Method                       |    Type                  |    Description                 |
|---------------------------------|--------------------------|--------------------------------|
| focus                           | a -> (a -> Void) -> Void | `this.refs.selectInstance.focus(callback)` opens the list of options and positions the cursor in the input control, the callback fired when the options menu becomes visible|
| highlightFirstSelectableOption  | a -> Void                | `this.refs.selectInstance.highlightFirstSelectableOption()`|
| value                           | a -> Item                | `this.refs.selectInstance.value()` returns the current selected item|

### MultiSelect props
In addition to the props above

|    Property                |   Type                               |   Description|
|--------------------------- |--------------------------------------|---------------------------------|
|    anchor                  | Item                                 | positions the cursor ahead of the anchor item, set this property to undefined to lock the cursor at the start|
|    createFromSearch        | [Item] -> [Item] -> String -> Item?  | function(options, values, search){return {label: search, value: search}}|
|    defaultValues           | [Item]                               | similar to the defaultValue prop of React.DOM.Select but instead takes an array of items|
|    filterOptions           | [Item] -> [Item] -> String -> [Item] | function(options, values, search){return options}|
|    onAnchorChange          | Item -> (a -> Void) -> Void          | function(anchor, callback){callback();} implement this method if you want to override the default behaviour of the cursor|
|    onBlur                  | [Item] -> String -> Void             | function(values, reason){}|
|    onFocus                 | [Item] -> String -> Void             | function(values, reason){}|
|    onValuesChange          | [Item] -> (a -> Void) -> Void        | function(values, callback){callback();}|
|    maxValues               | Int                                  | the maximum values that can be selected, after which the control is disabled|
|    closeOnSelect           | Boolean                              | as the name implies, closes the options list on selecting an option|
|    valuesFromPaste         | [Item] -> [Item] -> String ->[Item]  | `function(options, values, pastedText){}` invoked when the user pastes text in the input field, here you can convert the pasted text into a list of items that will then show up as selected |

### MultiSelect methods
same as SimpleSelect but use `this.refs.multiSelectInstance.values()` to get the selected values instead of the `value` method.

### HighlightedText props
used for [search highlighting](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=search-highlighting)

|    Property                |   Type                               |   Description|
|--------------------------- |--------------------------------------|---------------------------------|
|    partitions              | [[Int, Int, Boolean]]                | collection of ranges which should or should not be highlighted, its the result of the partitionString method of the [prelude-extension](https://www.npmjs.com/package/prelude-extension) library|
|    text                    | String                               | the string that is partitioned, the partitions collection above only has the ranges & so we need to pass the original text as well|
|    style                   | inline CSS styles object             | inline styles applied to the root node|
|    highlightStyle          | inline CSS styles object             | inline styles applied to the highlighted spans|
