
{EventEmitter} = require 'events'
count = 0
module.exports = (mecano) ->
  child = new EventEmitter
  child.todos = []
  for k, v of mecano
    do (k) ->
      child[k] = (options, callback) ->
        child.todos.push [k, arguments]
        child
  child.end = (err, modified) ->
    todo = child.todos.shift()
    if err or not todo
      if child.listeners('error').length
        if err
        then child.emit 'error', new Error 'What the hell'
        else child.emit 'end', modified
      else
        child.emit 'both', err, modified
      return
    c = mecano[todo[0]].apply null, todo[1]
    c.id = "chidle #{count++}"
    c.on 'error', (err) ->
      child.end err, 0
    c.on 'end', (modified) ->
      child.end null, modified
  child