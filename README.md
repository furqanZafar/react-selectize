[![Build Status](https://travis-ci.org/furqanZafar/react-selectize.svg?branch=develop)](https://travis-ci.org/furqanZafar/react-selectize)    [![Coverage Status](https://coveralls.io/repos/furqanZafar/react-selectize/badge.svg?branch=develop&service=github)](https://coveralls.io/github/furqanZafar/react-selectize?branch=develop)

# Motivation
* existing components do not behave like built-in React.DOM.* components. 
* existing components [synchronize props with state](http://facebook.github.io/react/tips/props-in-getInitialState-as-anti-pattern.html) an anti pattern, which makes them prone to bugs & difficult for contributers to push new features without breaking something else.
* more features.

# React Selectize
`ReactSelectize` is a stateless Select component for ReactJS, that provides a platform for the more developer friendly `SimpleSelect` & `MultiSelect` components. 

Both `SimpleSelect` & `MultiSelect` have been designed to work as drop in replacement for the built-in `React.DOM.Select` component.

styles & features inspired by [React Select](http://jedwatson.github.io/react-select/) & [Selectize](http://brianreavis.github.io/selectize.js/).

LIVE DEMO: [furqanZafar.github.io/react-selectize](http://furqanZafar.github.io/react-selectize/)

[![](http://i.imgsafe.co/rQmogzn.gif)](http://furqanZafar.github.io/react-selectize/)

## Features
* [Drop in replacement for React.DOM.Select](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=drop-in-replacement-for-react.dom.select)
* Stateless, therefore extremely flexible & extensible
* Clean and compact API fully documented on GitHub
* [Multiselect support](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=multi-select)
* [Option groups](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=option-groups)
* [Custom filtering &amp; option object](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=custom-filtering-and-rendering)
* [Search highlighting](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=search-highlighting)
* [Custom option &amp; value rendering](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=custom-option-and-value-rendering)
* [Remote data loading](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=remote-options)
* [Tagging or item creation](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=tags)
* [Restore on backspace](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=restore-on-backspace)
* [Editable value](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=editable-value)
* [Caret between items](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=tags)
* [Customizable dropdown direction](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=dropdown-direction)
* [Mark options as unselectable](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=selectability)
* [Disable selected values](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=disable-selected)
* Customizable styles, comes with Stylus files

## Install
`npm install react-selectize`

## Usage (livescript)
```
{create-factory}:React = require \react
{SimpleSelect, MultiSelect, ReactSelectize} = require \react-selectize
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
ReactSelectize = require("react-selectize");
SimpleSelect = React.createFactory(ReactSelectize.SimpleSelect);
MultiSelect = React.createFactory(ReactSelectize.MultiSelect);
.
.
.
<SimpleSelect
    placeholder = "Select a fruit"
    onValueChange = {function(value, callback){
        alert(value);
        callback();
    }}
>
    <option value = "apple">apple</option>
    <option value = "mango">mango</option>
    <option value = "orange">orange</option>
    <option value = "banana">banana</option>
</SimpleSelect>
.
.
.
// Note: options can be passed as props as well, for example
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
to include the default styles add the following import statement to your stylus file:

`@import 'node_modules/react-selectize/src/index.css'`


## Gotchas
* the default structure of an option object is `{label: String, value :: a}` where `a` implies that `value` property can be of any equatable type

* SimpleSelect notifies change via `onValueChange` prop whereas MultiSelect notifies change via `onValuesChange` prop

* the onValueChange callback for SimpleSelect is passed 2 parameters. the `selected option object` (instead of the value property of the option object) and a `callback`

* the onValuesChange callback for MultiSelect is passed 2 parameters an Array  of selected option objects (instead of a collection of the value properties or a comma separated string of value properties) and a `callback`

* all the `on*Change` functions receive a callback as the final parameter, which MUST always be invoked, for example when using state for the `value` prop of `SimpleSelect` the `onValueChange` callback implementation would look like this:
``` jsx
value = {{label: "apple", value: "apple"}}
onValueChange = {function(value, callback){
    self.setState(value, callback);
}}
```
when relying on the components internal state for managing the value:
``` jsx
onValueChange = {function(value, callback){
    console.log(value);
    callback(); // must invoke callback    
}}
```

* when using custom option object, you should implement the `uid` function which accepts an option object and returns a unique id, for example:
``` jsx
// assuming the type of our option object is:
// {firstName :: String, lastName :: String, age :: Int}
uid = {function(item){
    return item.firstName + item.lastName;    
}}
```
the `uid` function is used internally for performance optimization. 

## SimpleSelect props

|    Property                |   Type                         |   Description                  |
|----------------------------|--------------------------------|--------------------------------|
|    autosize                | InputElement -> Int            | `function($search){return $search.value.length * 10}` custom logic for autosizing the input element|
|    className               | String                         | class name for the outer element, in addition to "simple-select"|
|    createFromSearch        | [Item] -> String -> Item?      | implement this function to create new items on the fly, `function(options, search){return {label: search, value: search}}`, return null to avoid option creation for the given parameters|
|    disabled                | Boolean                        | disables interaction with the Select control|
|    dropdownDirection       | Int                            | defaults to 1, setting it to -1 opens the dropdown upward|
|    editable                | Boolean                        | defaults to false, setting it to true makes the selected option editable|
|    filterOptions           | [Item]-> String -> [Item]      | implement this function for custom synchronous filtering logic, `function(options, search) {return options}`|
|    groupId                 | Item -> b                      | `function(item){return item.groupId}` this function is used to identify which group an option belongs to, it must return a value that matches the groupId property of an object in the groups collection|
|    groups                  | [Group]                        | collection of objects where each object must atleast have a groupId property|
|    groupsAsColumns         | Boolean                        | display option groups in columns|
|    onBlur                  | Item -> String -> Void         | `function(value, reason){}` reason can be either "click" (loss of focus because the user clicked elsewhere), "tab" or "blur" (invoked refs.simpleSelect.blur())|
|    onFocus                 | Item -> String -> Void         | `function(value, reason){}` reason can be either "event" (when the control gains focus outside) or "focus" (when the user invokes refs.simpleSelect.focus())|
|    onSearchChange          | String -> (a -> Void) -> Void  | `function(search, callback){self.setState({search: search}, callback);}` or `function(search,callback){callback();}` i.e. callback MUST always be invoked|
|    onValueChange           | Item -> (a -> Void) -> Void    | `function(selectedValue, callback){self.setState({selectedValue: selectedValue}, callback)}` or `function(value, callback){callback()}` i.e. callback MUST always be invoked|
|    options                 | [Item]                         | list of items by default each option object MUST have label & value property, otherwise you must implement the render* & filterOptions methods|
|    placeholder             | String                         | displayed when there is no value|
|    renderNoResultsFound    | Item -> String -> ReactElement | `function(item, search){return React.DOM.div(null);}` returns a custom way for rendering the "No results found" error|
|    renderGroupTitle        | Int -> Group -> ReactElement   | `function(index, group){return React.DOM.div(null)}` returns a custom way for rendering the group title|
|    renderOption            | Item -> ReactElement           | `function(item){return React.DOM.div(null);}` returns a custom way for rendering each option|
|    renderValue             | Item -> ReactElement           | `function(item){return React.DOM.div(null);}` returns a custom way for rendering the selected value|
|    restoreOnBackspace      | Item -> String                 | `function(item){return item.label;}` implement this method if you want to go back to editing the item when the user hits the [backspace] key instead of getting removed|
|    search                  | String                         | the text displayed in the search box|
|    style                   | Object                         | the CSS styles for the outer element|
|    uid                     | (Eq e) => Item -> e            | `function(item){return item.value}` returns a unique id for a given option, defaults to the value property|
|    value                   | Item                           | the selected value, i.e. one of the objects in the options array|

## SimpleSelect methods

|    Method                       |    Type                  |    Description                 |
|---------------------------------|--------------------------|--------------------------------|
| focus                           | a -> (a -> Void) -> Void | `this.refs.selectInstance.focus(callback)` opens the list of options and positions the cursor in the input control, the callback fired when the options menu becomes visible|
| highlightFirstSelectableOption  | a -> Void                | `this.refs.selectInstance.highlightFirstSelectableOption()`|
| value                           | a -> Item                | `this.refs.selectInstance.value()` returns the current selected item|

## MultiSelect props
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

## MultiSelect methods
same as SimpleSelect but use `this.refs.multiSelectInstance.values()` to get the selected values instead of the `value` method.

## HighlightedText props
used for [search highlighting](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=search-highlighting)

|    Property                |   Type                               |   Description|
|--------------------------- |--------------------------------------|---------------------------------|
|    partitions              | [[Int, Int, Boolean]]                | collection of ranges which should or should not be highlighted, its the result of the partitionString method of the [prelude-extension](https://www.npmjs.com/package/prelude-extension) library|
|    text                    | String                               | the string that is partitioned, the partitions collection above only has the ranges & so we need to pass the original text as well|
|    style                   | inline CSS styles object             | inline styles applied to the root node|
|    highlightStyle          | inline CSS styles object             | inline styles applied to the highlighted spans|


## Development
* `npm install`
* `gulp`
* visit `localhost:8000`
* `npm test` , `npm run coverage` for unit tests & coverage
* for production build/test run `MINIFY=true gulp`
