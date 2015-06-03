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
      obj.registry ?= {}
      obj.propagated_options ?= []
      for option in module.exports.propagated_options then obj.propagated_options.push option
      properties = {}
      stack = []
      todos = []
      todos.err = null
      todos.changed = false
      todos.throw_if_error = true
      call_callback = (fn, args) ->
        stack.unshift todos
        todos = []
        todos.err = null
        todos.changed = false
        todos.throw_if_error = true
        try
          result = fn.apply obj, args
        catch err
          todos = stack.shift()
          jump_to_error err
          return run()
        mtodos = todos
        todos = stack.shift()
        todos.unshift mtodos... if mtodos.length
        result
      call_sync = (fn, args) ->
        stack.unshift todos
        todos = []
        todos.err = null
        todos.changed = false
        todos.throw_if_error = true
        try
          result = fn.apply obj, args
        catch err
          todos = stack.shift()
          jump_to_error err
          return run()
        mtodos = todos
        todos = stack.shift()
        todos.unshift mtodos... if mtodos.length
        result
      call_async = (fn, local_options={}, callback) ->
        global_options = obj.options
        parent_options = todos.options
        local_options_array = Array.isArray local_options
        local_options = [local_options] unless local_options_array
        options = []
        for local_opts in local_options
          local_opts = argument: local_opts if local_opts? and typeof local_opts isnt 'object'
          opts = {}
          for k, v of local_opts then opts[k] = local_opts[k]
          options.push opts
        for k, v of parent_options
          for opts in options then opts[k] = v if opts[k] is undefined and k in obj.propagated_options
        for k, v of global_options
          for opts in options then opts[k] = v if opts[k] is undefined
        try
          stack.unshift todos
          todos = []
          todos.err = null
          todos.changed = false
          todos.throw_if_error = true
          finish = (err, changed) ->
            toto = for k in changed then k
            arguments[0] ?= null
            arguments[1] = !!changed.some (status) -> status unless err
            toto = toto[0] unless local_options_array
            arguments.length = 2 if arguments.length is 0
            todos = stack.shift() if todos.length is 0
            todos.throw_if_error = false if err and callback
            jump_to_error err if err
            call_callback callback, arguments if callback
            if Array.isArray options
            then for opts, i in options then status = true if toto[i] and not err and not opts.shy
            else status = true if toto and not err and not options.shy
            todos.changed = status if status
            return run()
          options = options[0] unless local_options_array
          wrap obj, [options, finish], (options, callback) ->
            todos.options = options
            fn.call obj, options, (err, status, args...) ->
              # status = if options.shy then false else status
              callback err, status, args...
        catch err
          todos = stack.shift()
          jump_to_error err
          run()
      jump_to_error = (err) ->
        while todos[0] and todos[0][0] isnt 'then' then todos.shift()
        todos.err = err
        # return run()
      run = ->
        todo = todos.shift()
        unless todo # Nothing more to do in current queue
          throw todos.err if todos.err and todos.throw_if_error
          return
        if todo[0] is 'then'
          {err, changed} = todos
          todos.err = null
          todos.changed = false
          todos.throw_if_error = true
          todo[1][0].call obj, err, changed
          run()
          return
        if todo[0] is 'call'
          if todo[1][0].length is 2 # Async style
            return call_async todo[1][0], null, null
          else # Sync style
            changed = call_sync todo[1][0], []
            if changed then todos.changed = true
            return run()
        # Enrich with default options
        # if Array.isArray todo[1][0]
        #   for t in todo[1][0]
        #     for k, v of obj.options
        #       t[k] = obj.options[k] if typeof t[k] is 'undefined'
        # else if typeof todo[1][0] is 'object'
        #   t = todo[1][0]
        #   for k, v of obj.options
        #     t[k] = obj.options[k] if typeof t[k] is 'undefined'
        # Call the action
        todo[1][0].user_args = todo[1][1]?.length > 2
        fn = obj.registry[todo[0]] or registry[todo[0]]
        call_async fn, todo[1][0], todo[1][1]
      properties.child = get: ->
        ->
          module.exports(obj.options)
      properties.then = get: ->
        ->
          # id = status.id++
          todos.push ['then', arguments]
          process.nextTick run if todos.length is 1 # Activate the pump
          obj
      properties.call = get: ->
        ->
          # id = status.id++
          todos.push ['call', arguments]
          process.nextTick ->
          process.nextTick run if todos.length is 1 # Activate the pump
          obj
      proto = Object.defineProperties obj, properties
      # Register function
      Object.defineProperty obj, 'register', get: ->
        (name, handler) ->
          is_registered_locally = obj.registered name, true
          if handler is null or handler is false
            if is_registered_locally
              delete obj.registry[name]
              delete obj[name] 
            else if module.exports.registered name
              throw Error 'Unregister a global function from local context'
            return obj
          throw Error "Function already defined '#{name}'" if is_registered_locally
          obj.registry[name] = handler
          Object.defineProperty obj, name, configurable: true, get: ->
            ->
              # id = status.id++
              dest = arguments[0]?.destination
              todos.push [name, arguments]
              process.nextTick run if todos.length is 1 # Activate the pump
              obj
      Object.defineProperty obj, 'registered', get: ->
        (name, local_only=false) ->
          global = Object.prototype.hasOwnProperty.call module.exports, name
          local = Object.prototype.hasOwnProperty.call obj, name
          if local_only then local else global or local
      obj.register name, handler for name, handler of registry
      obj

    module.exports.propagated_options = ['ssh', 'log', 'stdout', 'stderr']

## Register functions

Register a new function available when requiring mecano and inside any mecano
instance. 

You can also un-register a existing function by passing "null" or "false" as
the second argument. It will return "true" if the function is un-registered or
"false" if there was nothing to do because the function wasn't already
registered.

    register = module.exports.register = (name, handler) ->
      if handler is null or handler is false
        delete registry[name] if registered name
        delete module.exports[name] if registered name
        return module.exports
      throw Error "Function already defined '#{name}'" if registered name
      registry[name] = handler unless name is 'call'
      Object.defineProperty module.exports, name, 
        configurable: true
        get: -> module.exports()[name]

    registered = module.exports.registered = (name) ->
      Object.prototype.hasOwnProperty.call module.exports, name

Pre-register mecano internal functions

    registry = require './misc/registry'
    register name, handler for name, handler of registry
    register 'call', module.exports().call
    

    wrap = require './misc/wrap'
