require! \fs
$ = require \jquery-browserify
require \livescript
{compile} = require \livescript
{concat-map, drop, filter, find, fold, group-by, id, last, map, Obj, obj-to-pairs, pairs-to-obj, 
reject, reverse, Str, sort-by, take, unique,  unique-by, values, zip-with} = require \prelude-ls
{create-factory, DOM:{a, button, div, form, h1, h2, img, input, li, ol, span, ul}}:React = require \react
require! \react-tools
Example = create-factory require \./Example.ls
require! \MultiSelect.ls
require! \SimpleSelect.ls
_ = require \underscore

examples = 
    * title: "Multi select"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/multi/MultiSelect.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/multi/MultiSelect.ls, \utf8 

    * title: "Max values"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/multi/MaxValues.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/multi/MaxValues.ls, \utf8 
    
    * title: "Tags"
      description: "create options from search"
      languages:
        jsx: fs.read-file-sync \public/examples/multi/Tags.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/multi/Tags.ls, \utf8 

    * title: "Cursor"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/multi/Cursor.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/multi/Cursor.ls, \utf8 
    
    * title: "Custom filtering & rendering"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/multi/CustomRendering.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/multi/CustomRendering.ls, \utf8 
    
    * title: "Simple select"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/simple/SimpleSelect.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/simple/SimpleSelect.ls, \utf8 
    
    * title: "Restore on backspace"
      description: "Press the [backspace] key and go back to editing the item without it being fully removed."
      languages:
        jsx: fs.read-file-sync \public/examples/simple/RestoreOnBackspace.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/simple/RestoreOnBackspace.ls, \utf8 
    
    * title: "Create from search"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/simple/CreateFromSearch.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/simple/CreateFromSearch.ls, \utf8 
    
    * title: "Event listeners"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/simple/EventListeners.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/simple/EventListeners.ls, \utf8 
    
    * title: "Custom option & value rendering"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/simple/CustomRendering.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/simple/CustomRendering.ls, \utf8 
    
    * title: "Selectability"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/simple/Selectability.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/simple/Selectability.ls, \utf8 
    
    * title: "Remote options"
      description: ""
      languages:
        jsx: fs.read-file-sync \public/examples/simple/RemoteOptions.jsx, \utf8 
        ls: fs.read-file-sync \public/examples/simple/RemoteOptions.ls, \utf8 
    ...

App = React.create-class do

    display-name: \App

    # render :: a -> ReactElement
    render: -> 
        div class-name: \app,
            div class-name: \title, 'React Selectize'
            div class-name: \examples,
                examples |> map ({title, description, {jsx, ls}:languages}) ~>
                    Example do 
                        title: title
                        description: description
                        width: 850
                        style: margin-top: 100
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

React.render (React.create-element App, null), document.body