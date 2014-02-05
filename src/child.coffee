
{EventEmitter} = require 'events'
count = 0
module.exports = (mecano) ->
  child = new EventEmitter
  child.todos = []
  for k, v of mecano
    do (k) ->
      child[k] = (options, callback) ->
        # console.log 'call', k, arguments
        child.todos.push [k, arguments]
        child
  child.end = (err, modified) ->
    # console.log '==========================',  err, child.todos.length
    todo = child.todos.shift()
    # console.log '--------------------------',  err, todo
    if err or not todo
      if child.listeners('error').length
        if err
        # then child.emit 'error', new Error 'What the hell'
        then child.emit 'error', err
        else child.emit 'end', modified
      else
        child.emit 'both', err, modified
      return
    c = mecano[todo[0]].apply null, todo[1]
    c.id = "child #{count++}"
    c.on 'error', (err) ->
      child.end err, 0
    c.on 'end', (modified) ->
      child.end null, modified
  child