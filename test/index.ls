require! \jsdom
global <<< 
    document: jsdom.jsdom '<!doctype html><html><body></body></html>'
    navigator: user-agent: \JSDOM
    window: document.parent-window
require! \./simple-select
require! \./multi-select