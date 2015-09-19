# React Selectize
A flexible & stateless select component for ReactJS built with livescript and love. 
ReactSelectize comes in 3 flavours SimpleSelect (or single select), MultiSelect & ReactSelectize. Both the SimpleSelect & the MultiSelect components are built on top of the stateless ReactSelectize component.

LIVE DEMO: [furqanZafar.github.io/react-selectize](http://furqanZafar.github.io/react-selectize/)

[![](http://i.imgur.com/nk2BSGp.gif)](http://furqanZafar.github.io/react-selectize/)

## Install

`npm install react-selectize`

## Usage (livescript)

```
{create-factory}:React = require \react
{SimpleSelect, MultiSelect, ReactSelectize} = require \ReactSelectize
SimpleSelect = create-factory SimpleSelect
MultiSelect = create-factory MultiSelect
.
.
.
SimpleSelect do     
    placeholder: 'Select a fruit'
    options: <[apple mango orange banana]> |> map ~> label: it, value: it
    on-value-change: (value, callback) ~>
        alert value
        callback!
.
.
.
MultiSelect do
    placeholder: 'Select fruits'
    options: <[apple mango orange banana]> |> map ~> label: it, value: it
    on-values-change: (values, callback) ~>
        alert values
        callback!
```

## Usage (jsx)

```
React = require("react");
ReactSelectize = require("ReactSelectize");
SimpleSelect = React.createFactory(ReactSelectize.SimpleSelect);
MultiSelect = React.createFactory(ReactSelectize.MultiSelect);
.
.
.
<SimpleSelect
    placeholder = "Select a fruit"
    options = ["apple", "mango", "orange", "banana"].map(function(fruit){
        return {label: fruit, value: fruit};
    });
    onValueChange = {function(value, callback){
        alert(value);
        callback();
    }}
/>
.
.
.
<MultiSelect
    placeholder = "Select fruits"
    options = ["apple", "mango", "orange", "banana"].map(function(fruit){
        return {label: fruit, value: fruit};
    });
    onValuesChange = {function(values, callback){
        alert(values);
        callback();
    }}
/>
```

## Usage (stylus)
to include the default styles when using SimpleSelect component, add the following import statement to your stylus file:

`@import 'node_modules/react-selectize/src/SimpleSelect.css'`

to include the default styles when using MultiSelect component, add the following import statement to your stylus file:

`@import 'node_modules/react-selectize/src/MultiSelect.css'`

## SimpleSelect Props

|    Property                |   Type                             |   Description|
|----------------------------|------------------------------------|--------------------------------|
|    autosize                | InputElement -> Int                | `function($search){return $search.value.length * 10}` custom logic for autosizing the input element, the default implementation uses scroll-width, if supported, otherwise it simply multiples the text length with a constant|
|    className               | String                             | class name for the outer element, in addition to "simple-select"|
|    disabled                | Boolean                            | disables interaction with the Select control|
|    createFromSearch        | [Item] -> String -> Item?          | implement this function to create new items on the fly, `function(options, search){return {label: search, value: search}}`, return null to avoid option creation for the given parameters|
|    filterOptions           | [Item]-> String -> [Item]          | implement this function for custom synchronous filtering logic, `function(options, search) {return options}`|
|    onBlur                  | Item -> String -> Void             | `function(value, reason){}` reason can be either "click" (loss of focus because the user clicked elsewhere), "tab" or "blur" (invoked refs.simpleSelect.blur())|
|    onFocus                 | Item -> String -> Void             | `function(value, reason){}` reason can be either "event" (when the control gains focus outside) or "focus" (when the user invokes refs.simpleSelect.focus())|
|    onSearchChange          | String -> (a -> Void) -> Void      | `function(search, callback){self.setState({search: search}, callback);}` or `function(search,callback){callback();}` i.e. callback MUST always be invoked|
|    onValueChange           | Item -> (a -> Void) -> Void        | `function(selectedValue, callback){self.setState({selectedValue: selectedValue}, callback)}` or `function(value, callback){callback()}` i.e. callback MUST always be invoked|
|    options                 | [Item]                             | list of items by default each option object MUST have label & value property, otherwise you must implement the render* & filterOptions methods|
|    placeholder:            | String                             | displayed when there is no value|
|    renderNoResultsFound    | Item -> String -> ReactElement     | `function(item, search){return React.DOM.div(null);}` returns a custom way for rendering the "No results found" error|
|    renderOption            | Int -> Item -> ReactElement        | `function(index, item){return React.DOM.div(null);}` returns a custom way for rendering each option|
|    renderValue             | Int -> Item -> ReactElement        | `function(index, item){return React.DOM.div(null);}` returns a custom way for rendering the selected value|
|    restoreOnBackspace      | Item -> String                     | `function(item){return item.label;}` implement this method if you want to go back to editing the item when the user hits the [backspace] key instead of getting removed|
|    search                  | String                             | the text displayed in the search box|
|    style                   | Object                             | the CSS styles for the outer element|
|    value                   | Item                               | the selected value, i.e. one of the objects in the options array|

## SimpleSelect methods

|    Method                       |    Type                            |    Description                 |
|---------------------------------|------------------------------------|--------------------------------|
| focus                           | a -> Void                          | `this.refs.selectInstance.focus()` opens the list of options and positions the cursor in the input control|
| highlightFirstSelectableOption  | a -> Void                          | `this.refs.selectInstance.highlightFirstSelectableOption()`|
| value                           | a -> Item                          | `this.refs.selectInstance.value()` returns the current selected item|

## MultiSelect Props
In addition to the props above

|    Property                |   Type                               |   Description|
|--------------------------- |--------------------------------------|---------------------------------|
|    anchor                  | Item                                 | positions the cursor ahead of the anchor item, set this property to undefined to lock the cursor at the start|
|    createFromSearch        | [Item] -> [Item] -> String -> Item?  | function(options, values, search){return {label: search, value: search}}|
|    filterOptions           | [Item] -> [Item] -> String -> [Item] | function(options, values, search){return options}|
|    onAnchorChange          | Item -> (a -> Void) -> Void          | function(anchor, callback){callback();} implement this method if you want to override the default behaviour of the cursor|
|    onBlur                  | [Item] -> String -> Void             | function(values, reason){}|
|    onFocus                 | [Item] -> String -> Void             | function(values, reason){}|
|    onValuesChange          | [Item] -> (a -> Void) -> Void        | function(values, callback){callback();}|
|    maxValues               | Int                                  | the maximum values that can be selected, after which the control is disabled|
|    closeOnSelect           | Boolean                              | as the name implies, closes the options list on selecting an option|

## MultSelect methods

same as SimpleSelect but use `this.refs.multiSelectInstance.values()` to get the selected values instead of the `value` method.

## Development

* `npm install`
* copy the following to `config.ls`
```
module.exports = 
    minify: true
```
* `gulp`
* visit `localhost:8000`

