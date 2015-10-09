require! \fs
$ = require \jquery-browserify
require \livescript
{compile} = require \livescript
{concat-map, drop, filter, find, fold, group-by, id, keys, last, map, Obj, obj-to-pairs, pairs-to-obj, 
reject, reverse, Str, sort-by, take, unique,  unique-by, values, zip-with} = require \prelude-ls
{partition-string} = require \prelude-extension
{create-factory, DOM:{a, button, div, form, h1, h2, img, input, li, ol, option, span, ul}}:React = require \react
{find-DOM-node, render} = require \react-dom
require! \react-router
Link = create-factory react-router.Link
Route = create-factory react-router.Route
Router = create-factory react-router.Router
create-history = require \history/lib/createHashHistory
require! \react-tools
Example = create-factory require \./Example.ls
{HighlightedText, SimpleSelect, MultiSelect, ReactSelectize} = require \index.ls
_ = require \underscore

examples = 
    multi:
        * title: "Multi select"
          description: ""
          languages:
            jsx: fs.read-file-sync \public/examples/multi/MultiSelect.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/MultiSelect.ls, \utf8 

        * title: "On values change"
          description: ""
          languages:
            jsx: fs.read-file-sync \public/examples/multi/ChangeCallback.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/ChangeCallback.ls, \utf8 

        * title: "Max values"
          description: """
This example only allows 2 items. 
Select one more item and the control will be disabled until one or more are deleted.
"""
          languages:
            jsx: fs.read-file-sync \public/examples/multi/MaxValues.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/MaxValues.ls, \utf8 
        
        * title: "Tags"
          description: """
Add and remove items in any order without touching your mouse. 
Use your left/right arrow keys to move the cursor between items.
"""          
          languages:
            jsx: fs.read-file-sync \public/examples/multi/Tags.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/Tags.ls, \utf8 

        * title: "Option groups"
          description: """
Display option groups as columns by setting groupsAsColumns property to true
"""          
          languages:
            jsx: fs.read-file-sync \public/examples/multi/OptionGroups.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/OptionGroups.ls, \utf8 

        * title: "Dropdown direction"
          description: """
The following example flips the dropdown based on the screen Y value of the select component.
open the dropdown and scroll up and down past the select component
"""          
          languages:
            jsx: fs.read-file-sync \public/examples/multi/DropdownDirection.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/DropdownDirection.ls, \utf8 
            
        * title: "Cursor"
          description: """
To control the position of the cursor use the anchor & onAnchorChange props.
The cursor is placed ahead of the anchor item. 
To position the cursor at the start, set anchor to undefined
"""
          languages:
            jsx: fs.read-file-sync \public/examples/multi/Cursor.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/Cursor.ls, \utf8 
        
        * title: "Disable selected"
          description: ""
          languages:
            jsx: fs.read-file-sync \public/examples/multi/DisableSelected.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/DisableSelected.ls, \utf8 
        
        * title: "Custom filtering and rendering"
          description: """
This demonstrates two main things: 
 (1) custom item and option rendering, and 
 (2) custom item filtering, for example, try typing :) or <3
"""
          languages:
            jsx: fs.read-file-sync \public/examples/multi/CustomRendering.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/CustomRendering.ls, \utf8 
        ...

    simple:
        * title: "Simple select"
          description: ""
          languages:
            jsx: fs.read-file-sync \public/examples/simple/SimpleSelect.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/SimpleSelect.ls, \utf8 

        * title: "On value change"
          description: ""
          languages:
            jsx: fs.read-file-sync \public/examples/simple/ChangeCallback.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/ChangeCallback.ls, \utf8 

        * title: "Restore on backspace"
          description: """
Press the [backspace] key and go back to editing the item without it being fully removed.
"""
          languages:
            jsx: fs.read-file-sync \public/examples/simple/RestoreOnBackspace.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/RestoreOnBackspace.ls, \utf8 
        
        * title: "Create from search"
          description: """
Create item from search text
"""          
          languages:
            jsx: fs.read-file-sync \public/examples/simple/CreateFromSearch.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/CreateFromSearch.ls, \utf8 
        
        * title: "Drop in replacement for React.DOM.Select"
          description: ""
          languages:
            jsx: fs.read-file-sync \public/examples/simple/Children.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/Children.ls, \utf8 

        * title: "Event listeners"
          description: """
A demonstration showing how to use the API to cascade controls for a classic make / model selector
"""          
          languages:
            jsx: fs.read-file-sync \public/examples/simple/EventListeners.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/EventListeners.ls, \utf8 
        
        * title: "Search highlighting"
          description: ""
          languages: 
            jsx: fs.read-file-sync \public/examples/simple/SearchHighlighting.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/SearchHighlighting.ls, \utf8 

        * title: "Custom option and value rendering"
          description: ""
          languages:
            jsx: fs.read-file-sync \public/examples/simple/CustomRendering.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/CustomRendering.ls, \utf8 
        
        * title: "Selectability"
          description: """
Freeze options using the selectable property
"""          
          languages:
            jsx: fs.read-file-sync \public/examples/simple/Selectability.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/Selectability.ls, \utf8 
        
        * title: "Remote options"
          description: """
This demo shows how to integrate third-party data from cdn.js
"""          
          languages:
            jsx: fs.read-file-sync \public/examples/simple/RemoteOptions.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/simple/RemoteOptions.ls, \utf8 
        ...

App = React.create-class do

    display-name: \App

    # get-default-props :: a -> Props
    get-default-props: ->
        query:
            category: \multi
            # example :: String

    # render :: a -> ReactElement
    render: -> 
        selected-category = @props.location.query?.category ? \multi
        
        # APP
        div class-name: \app,
            
            # CATEGORIES
            div class-name: \categories,
                div class-name: \line
                <[multi simple]> |> map (category) ~> 
                    Link do
                        key: category
                        class-name: if category == selected-category then \selected else ''
                        on-click: ~> console.log \apple
                        to: "?category=#{category}"
                        category
                div class-name: \line

            # EXAMPLES
            div class-name: \examples,
                examples[selected-category] |> map ({title, description, {jsx, ls}:languages}) ~>
                    key = "#{title.to-lower-case!.replace /\s+/g, '-'}"
                    Example do 
                        key: key
                        ref: key
                        title: title
                        description: description
                        width: 850
                        style: 
                            margin-bottom: 100
                        initial-language: \livescript
                        languages: 
                            * id: \livescript
                              name: "Livescript"
                              initial-content: ls
                              on-execute: (content, mount-node) -> eval compile content, {bare: true}
                            * id: \jsx
                              name: "JSX"
                              initial-content: jsx
                              on-execute: (content, mount-node) -> eval react-tools.transform content
                            * id: \javascript
                              name: "JS"
                              initial-content: react-tools.transform jsx
                              on-execute: (content, mount-node) -> eval content
    
    # scroll-to-example :: a -> Void
    scroll-to-example: !->
        example-element = find-DOM-node @refs?[@props.location.query.example]
        if !!example-element
            <~ set-timeout _, 150
            example-element.scroll-into-view!

    # external links
    # component-did-mount :: a -> Void
    component-did-mount: !-> @scroll-to-example!

    # changing the query string manually, or clicking on a different example
    # component-did-update :: Props -> Void
    component-did-update: (prev-props) !-> @scroll-to-example!
            
render do 
    Router do 
        history: create-history query-key: false
        Route path: \/, component: App
    document.get-element-by-id \mount-node