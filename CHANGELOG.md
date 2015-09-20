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