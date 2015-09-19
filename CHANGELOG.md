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

## v0.1.6 / 19h September 2015
* introduced a new prop `autosize`, allows consumers to provide custom autosize logic for search input, the default implementation now supports nonmodern browsers
