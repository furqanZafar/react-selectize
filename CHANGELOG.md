# React Selectize

## v0.1.1 / 11th September 2015
* added `highlightFirstSelectableOption` method to both the SimpleSelect & the MultiSelect components.
* changed filterOptions signature for SimpleSelect from `[Item] -> Item -> String -> [Item]` to `[Item]-> String -> [Item]`

## v0.1.2 / 11th September 2015
* updated package.json added keywords & removed license property

## v0.1.3 / 12th September 2015
* fixed a bug where invoking the callback onValueChange synchronously would not close the options menu
* fixed a bug where the SimpleSelect onValueChange callback was invoked even when the user selected the same item
* minor tweaks & improvements to the default stylesheet

## v0.1.4 / 15th September 2015
* fixed option menu toggle on tap/click in mobile safari

## v0.1.6 / 19th September 2015
* introduced a new prop `autosize`, allows consumers to provide custom autosize logic for search input, the default implementation now supports nonmodern browsers

## v0.2.0 / 19th September 2015
* drop in replacement for React.DOM.Select, accepts options as children
* added a new prop `dropdownDirection`, setting it to -1 forces the options menu to open upwards
* option group support (as rows and columns)
* updated the signature of refs.selectInstance.focus from `a -> Void` to `a -> (a -> Void) -> Void`, i.e. the focus function now accepts a callback as the first parameter which is fired when the options menu is visible
* improved performance by implementing shouldComponentUpdate lifecycle method for *Wrapper classes, added `uid :: (Eq e) => Item -> e` prop
* changed the signature of renderOption & renderValue props from `Int -> Item -> ReactElement` to `Item -> ReactElement`

## v0.2.1 / 20th September 2015
* fixed React Warnings caused by missing key property for ValueWrapper components
* allowing for wide range of react versions including 0.14.x-rc*
* uid property for MultiSelect components

## v0.2.2 / 21st September 2015
* fixed a bug where the input element would not autosize on entering search text
* avoid firing onValueChange with undefined value when the user enters new search text

## v0.2.3 / 23rd September 2015
* fixed a bug where passing a single child element would not show up in the dropdown
* fixed other minor bugs identified by unit testing

## v0.2.4 / 26th September 2015
* perf optimization, using result of props.uid method to compare items instead of deep equals
* added HighlightedText component to help with search highlighting

## v0.2.5 / 28th September 2015
* create index.css to fix style duplication when importing both SimpleSelect.css & MultiSelect.css
* clicking on the arrow button toggles the dropdown
* minor css tweaks

## v0.2.6 / 8th October 2015
* fixed a bug where selecting an option did not update the highlighted-uid (multi select). Thanks @edgarzakaryan

## v0.3.0 / 9th October 2015
* upgraded to react 0.14.0
* you can now return an object from the uid prop, made uid prop optional (even for custom option object)
* added `editable` prop for `SimpleSelect`
* fixed a bug where changing the selectable property would not rerender the option
* wrap around when navigating options with arrow keys
* close multi-select when there are no more options left to select