require! \fs
$ = require \jquery-browserify
require \livescript
{compile} = require \livescript
{concat-map, drop, filter, find, fold, group-by, id, keys, last, map, Obj, obj-to-pairs, pairs-to-obj, 
reject, reverse, Str, sort-by, take, unique,  unique-by, values, zip-with} = require \prelude-ls
{create-factory, DOM:{a, button, div, form, h1, h2, img, input, li, ol, option, span, ul}}:React = require \react
require! \react-tools
Example = create-factory require \./Example.ls
require! \MultiSelect.ls
require! \SimpleSelect.ls
_ = require \underscore

examples = 
    multi:
        * title: "Multi select"
          description: ""
          languages:
            jsx: fs.read-file-sync \public/examples/multi/MultiSelect.jsx, \utf8 
            ls: fs.read-file-sync \public/examples/multi/MultiSelect.ls, \utf8 

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
        
        * title: "Custom filtering & rendering"
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
        
        * title: "Custom option & value rendering"
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

    # render :: a -> ReactElement
    render: -> 
        div class-name: \app,
            div class-name: \categories,
                <[multi simple]> |> map (category) ~> 
                    div do 
                        key: category
                        class-name: if category == @state.category then \selected else ''
                        on-click: ~> @set-state {category}
                        category
            div class-name: \examples,
                examples[@state.category] |> map ({title, description, {jsx, ls}:languages}) ~>
                    Example do 
                        key: "#{@state.category} #{title}"
                        title: title
                        description: description
                        width: 850
                        style: margin-bottom: 100
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

    # get-initial-state :: a -> UIState
    get-initial-state: ->
        category: \multi

React.render (React.create-element App, null), document.get-element-by-id \mount-point