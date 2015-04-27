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
      stack = []
      todos = []
      status = err: null, changed: false, throw_if_error: true, running: false, id: 0
      callid = 0
      call_sync = (fn, args) ->
        ++callid
        stack.unshift todos
        todos = []
        try
          result = fn.apply obj, args
        finally
          mtodos = todos
          todos = stack.shift()
          todos.unshift mtodos... if mtodos.length
          result
      call = (fn, args, callback) ->
        ++callid
        # On error, what shall we do:
        # - if a then is registered, jump to then and skip all actions
        # - if no then and a callback, let the callback deal with it
        # Call the user callback synchronously
        try
          stack.unshift todos
          todos = []
          fn.call obj, args..., (err, changed) ->
            if err
              has_then = false
              for todo in todos then has_then = true if todo[0] is 'then'
              while todos[0] and todos[0][0] isnt 'then' then todos.shift()
            result = false
            try
              call_sync callback, arguments if callback
              status.throw_if_error = false if err
              err = null if result is true
            catch e then err = e unless err
            if err then status.err = err
            else if changed then status.changed = true
            todos = stack.shift() if todos.length is 0
            return run()
        catch err
          todos = stack.shift()
          has_then = false
          for todo in todos then has_then = true if todo[0] is 'then'
          while todos[0] and todos[0][0] isnt 'then' then todos.shift()
          status.err = err
          return run true
      run = (force) ->
        todo = todos.shift()
        # Nothing more to do
        unless todo
          throw status.err if status.err and status.throw_if_error
          return
        if todo[0] is 'then'
          {err, changed} = status
          status.err = null
          status.changed = false
          status.throw_if_error = true
          todo[1][0].call obj, err, changed
          run true
          return
        if todo[0] is 'call'
          if todo[1][0].length # Async style
            return call todo[1][0], [], null
          else # Sync style
            try
              changed = todo[1][0].call obj
            catch err
            if err
              has_then = false
              for todo in todos then has_then = true if todo[0] is 'then'
              while todos[0] and todos[0][0] isnt 'then' then todos.shift()
            if err then status.err = err
            else if changed then status.changed = true
            return run true
        # Enrich with default options
        if Array.isArray todo[1][0]
          for t in todo[1][0]
            for k, v of obj.options
              t[k] = obj.options[k] if typeof t[k] is 'undefined'
        else if typeof todo[1][0] is 'object'
          t = todo[1][0]
          for k, v of obj.options
            t[k] = obj.options[k] if typeof t[k] is 'undefined'
        # Call the action
        todo[1][0].user_args = todo[1][1]?.length > 2
        call registry[todo[0]], [todo[1][0]], todo[1][1]
      properties.child = get: ->
        ->
          module.exports(obj.options)
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
      # Register function
      Object.defineProperty obj, 'register', get: ->
        (name, handler) ->
          is_registered_locally = obj.registered name, true
          if handler is null or handler is false
            if is_registered_locally
              delete obj[name] 
            else if module.exports.registered name
              throw Error 'Unregister a global function from local context'
            return obj
          throw Error "Function already defined '#{name}'" if is_registered_locally
          Object.defineProperty obj, name, configurable: true, get: ->
            ->
              id = status.id++
              dest = arguments[0]?.destination
              todos.push [name, arguments, id]
              process.nextTick run if todos.length is 1 # Activate the pump
              obj
      Object.defineProperty obj, 'registered', get: ->
        (name, local_only=false) ->
          global = Object.prototype.hasOwnProperty.call module.exports, name
          local = Object.prototype.hasOwnProperty.call obj, name
          if local_only then local else global or local
      obj

## Register functions

Register a new function available when requiring mecano and inside any mecano
instance. 

You can also un-register a existing function by passing "null" or "false" as
the second argument. It will return "true" if the function is un-registered or
"false" if there was nothing to do because the function wasn't already
registered.

    register = module.exports.register = (name, handler) ->
      if handler is null or handler is false
        delete module.exports[name] if registered name
        return module.exports
      throw Error "Function already defined '#{name}'" if registered name
      Object.defineProperty module.exports, name, get: (-> handler), configurable: true

    registered = module.exports.registered = (name) ->
      Object.prototype.hasOwnProperty.call module.exports, name

Pre-register mecano internal functions

    registry = require './misc/registry'

    Object.keys(registry).forEach (name) ->
      register name, module.exports()[name]
      # Object.defineProperty module.exports, name, get: (-> module.exports()[name]), configurable: true
    register 'call', module.exports().call
    # Object.defineProperty module.exports, 'call', get: (-> module.exports().call), configurable: true


