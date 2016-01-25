[![npm version](https://badge.fury.io/js/react-selectize.svg)](https://badge.fury.io/js/react-selectize)
[![Build Status](https://travis-ci.org/furqanZafar/react-selectize.svg?branch=develop)](https://travis-ci.org/furqanZafar/react-selectize)
[![Coverage Status](https://coveralls.io/repos/furqanZafar/react-selectize/badge.svg?branch=develop&service=github)](https://coveralls.io/github/furqanZafar/react-selectize?branch=develop)

# React Selectize
`ReactSelectize` is a stateless Select component for ReactJS, that provides a platform for the more developer friendly `SimpleSelect` & `MultiSelect` components. 

Both `SimpleSelect` & `MultiSelect` have been designed to work as drop in replacement for the built-in `React.DOM.Select` component.

styles & features inspired by [React Select](http://jedwatson.github.io/react-select/) & [Selectize](http://brianreavis.github.io/selectize.js/).

**DEMO / Examples**: [furqanZafar.github.io/react-selectize](http://furqanZafar.github.io/react-selectize/)

[![](http://i.imgsafe.co/rQmogzn.gif)](http://furqanZafar.github.io/react-selectize/)

- [Changelog](CHANGELOG.md) (last updated on 25th January 2016)
- [API Reference](API.md)

# Motivation
* existing components do not behave like built-in React.DOM.* components. 
* existing components [synchronize props with state](http://facebook.github.io/react/tips/props-in-getInitialState-as-anti-pattern.html) an anti pattern, which makes them prone to bugs & difficult for contributers to push new features without breaking something else.
* more features.

## Features
* [Drop in replacement for React.DOM.Select](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=drop-in-replacement-for-react.dom.select)
* Stateless, therefore extremely flexible & extensible
* Clean and compact API fully documented on GitHub
* [Multiselect support](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=multi-select)
* [Option groups](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=option-groups)
* [Custom filtering &amp; option object](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=custom-filtering-and-rendering)
* [Search highlighting](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=search-highlighting)
* [Custom option &amp; value rendering](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=custom-option-and-value-rendering)
* [Animated dropdown](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=animated-dropdown)
* [Remote data loading](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=remote-options)
* [Tagging or item creation](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=tags)
* [Restore on backspace](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=restore-on-backspace)
* [Editable value](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=editable-value)
* [Caret between items](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=tags)
* [Customizable dropdown direction](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=dropdown-direction)
* [Mark options as unselectable](http://furqanzafar.github.io/react-selectize/#/?category=simple&example=selectability)
* [Disable selected values](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=disable-selected)
* [Absolute positioned overlay, "Tether"ed to the search field](http://furqanzafar.github.io/react-selectize/#/?category=multi&example=tether)
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
SimpleSelect = ReactSelectize.SimpleSelect;
MultiSelect = ReactSelectize.MultiSelect;
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

## Deps
* [tether](https://github.com/HubSpot/tether)

## Peer Deps
* react
* react-dom
* react-addons-css-transition
* react-addons-shallow-compare

## Development
* `npm install`
* `gulp`
* visit `localhost:8000`
* `npm test` , `npm run coverage` for unit tests & coverage
* for production build/test run `MINIFY=true gulp`
