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

    module.exports = ->
      # obj = instance arguments...
      if arguments.length is 2
        obj = arguments[0]
        obj.options = arguments[1]
      else if arguments.length is 1
        obj = {}
        obj.options = arguments[0]
      else
        obj = {}
        obj.options = {}
      properties = {}
      todos = []
      status = err: null, changed: false, throw_if_error: true, running: false, id: 0
      run = (force) ->
        status.running = false if force
        return if status.running
        todo = todos.shift()
        # Nothing more to do
        unless todo
          throw status.err if status.err and status.throw_if_error
          return
        # There is an error so we search for the next then item
        return run(true) if status.err and todo[0] isnt 'then'
        if todo[0] is 'then'
          # return todo[1][0].call obj, status.err, status.changed, (err, changed) ->
          #   status.err = null
          #   status.changed = false
          #   status.throw_if_error = true
          #   if err then status.err = err
          #   else if changed then status.changed = true
          #   run()
          {err, changed} = status
          status.err = null
          status.changed = false
          status.throw_if_error = true
          return todo[1][0].call obj, err, changed
        if todo[0] is 'call'
          if todo[1][0].length # Async style
            try
              status.running = true
              return todo[1][0].call obj, (err, changed) ->
                if err then status.err = err
                else if changed then status.changed = true
                run(true)
            catch err
              status.err = err
            run(true)
          else # Sync style
            try
              changed = todo[1][0].call obj
            catch err
            if err then status.err = err
            else if changed then status.changed = true
            run(true)
          return
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
        todo[1][0].user_args = todo[1][1]?.length > 2
        status.running = true
        registry[todo[0]].call obj, todo[1][0], (err, changed, to) ->
          # Call the user callback synchronously
          result = false
          try
            result = todo[1][1]?.apply null, arguments
            status.throw_if_error = false if err
            err = null if result is true
          catch e then err = e unless err
          if err then status.err = err
          else if changed then status.changed = true
          run(true)
      properties.then = get: ->
        ->
          id = status.id++
          todos.push ['then', arguments, id]
          process.nextTick run if todos.length is 1 # Activate the pump
          obj
      properties.call = get: ->
        ->
          id = status.id++
          todos.push ['call', arguments, id]
          process.nextTick ->
            # run() if todos.length is 1 # Activate the pump
          process.nextTick run if todos.length is 1 # Activate the pump
          obj
      Object.keys(registry).forEach (name) ->
        properties[name] = get: ->
          ->
            id = status.id++
            dest = arguments[0]?.destination
            todos.push [name, arguments, id]
            process.nextTick run if todos.length is 1 # Activate the pump
            obj
      proto = Object.defineProperties obj, properties
      obj

    properties = {}

    registry = require './misc/registry'

    Object.keys(registry).forEach (name) ->
      properties[name] = get: ->
        module.exports()[name]

    properties.call = get: ->
      module.exports().call

    Object.defineProperties module.exports, properties




