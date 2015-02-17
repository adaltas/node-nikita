# Mecano

Mecano gather a set of functions usually used during system deployment. All the
functions share a common API with flexible options.

*   Run actions both locally and remotely over SSH.
*   Ability to see if an action had an effect through the second argument
    provided in the callback.
*   Common API with options and callback arguments and calling the callback with
    an error and the number of affected actions.
*   Run one or multiple actions depending on option argument being an object or
    an array of objects.

## Source Code

    instance = (options={}) ->
      obj = {}
      obj.options = options
      obj

    module.exports = ->
      obj = instance arguments...
      properties = {}
      todos = []
      status = err: null, changed: false, throw_if_error: true
      run = ->
        todo = todos.shift()
        # Nothing more to do
        unless todo
          throw status.err if status.err and status.throw_if_error
          return
        # There is an error so we search for the next then item
        return run() if status.err and todo[0] isnt 'then'
        if todo[0] is 'then'
          return todo[1][0].call obj, status.err, status.changed, (err, changed) ->
            status.err = null
            status.changed = false
            if err then status.err = err
            else if changed then status.changed = true
            run()
        # Convert options to array
        # if typeof todo[1][0] is 'object' and not Array.isArray todo[1][0]
        #   todo[1][0] = [todo[1][0]]
        # Enrich with default options
        if Array.isArray todo[1][0]
          for t in todo[1][0]
            for k, v of obj.options
              t[k] = obj.options[k] if typeof t[k] is 'undefined'
        else
          t = todo[1][0]
          for k, v of obj.options
            t[k] = obj.options[k] if typeof t[k] is 'undefined'

        # Call the action
        # console.log '!!', callback.length, todo[1][1].length
        todo[1][0].user_args = todo[1][1]?.length > 2
        registry[todo[0]].call obj, todo[1][0], (err, changed, to) ->
          # Call the user callback synchronously
          try
            todo[1][1]?.apply null, arguments
            status.throw_if_error = false
          catch e then err = e unless err
          if err then status.err = err
          else if changed then status.changed = true
          run()
      build = (name) ->
        builder = ->
          todos.push [name, arguments]
          obj
        # __proto__ is used because we must return a function, but there is
        # no way to create a function with a different prototype.
        # builder.__proto__ = proto
        builder
      properties.then = get: ->
        build 'then'
      Object.keys(registry).forEach (name) ->
        properties[name] = get: ->
          process.nextTick run if todos.length is 0 # Activate the pump
          build name
      proto = Object.defineProperties obj, properties
      obj

    registry = require './misc/registry'

    properties = {}
    Object.keys(registry).forEach (name) ->
      properties[name] = get: ->
        module.exports()[name]
    Object.defineProperties module.exports, properties




