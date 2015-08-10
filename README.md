# MultiSelect component for React

## Install

`npm install react-selectize`

## Usage

```
...
ReactSelectize do     
    placeholder: 'Select countries'
    values: @state.selected-countries
    options: @state.countries
    on-change: (selected-countries) ~> @set-state {selected-countries}
    on-options-change: (countries) ~> @set-state {countries}    
...
```