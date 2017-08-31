require! \jsdom
{ window } = new jsdom.JSDOM '<!doctype html><html><body></body></html>'
global <<< 
    document: window.document
    navigator: user-agent: \JSDOM
    window: window

    # introduction of the following poperty is caused by a react 16 bug.
    # for more information visit https://github.com/facebook/react/issues/9102
    requestAnimationFrame:->
        throw new Error 'requestAnimationFrame is not supported in Node'

require! \./simple-select
require! \./multi-select
require! \./highlighted-text