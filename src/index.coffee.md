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
      todos.status = []
      todos.throw_if_error = true
      afters = []
      normalize_arguments = (_arguments, type='call') ->
        is_array = false
        handler = null
        callback = null
        if typeof _arguments[0] is 'function'
          options = [{}]
        else if Array.isArray _arguments[0]
          is_array = true
          options = _arguments[0]
        else if _arguments[0] and typeof _arguments[0] is 'object'
          options = [_arguments[0]]
        else
          options = [argument: _arguments[0]]
        for option in options
          option.type = type
        for arg, i in _arguments
          continue if i is 0 and typeof arg isnt 'function'
          if typeof arg is 'function'
            if handler
              callback = arg
            else
              handler = arg
          else if Array.isArray arg
            console.log 'NOT SUPPORTED'
          else if typeof arg is 'object'
            for option in options
              option[k] = v for k, v of arg
          else
            for option in options
              options.argument = arg
        options = options[0] unless is_array
        type: type, options: options, handler: handler, callback: callback
      enrich_options = (user_options) ->
        global_options = obj.options
        parent_options = todos.options
        local_options_array = Array.isArray user_options
        local_options = user_options
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
        options = options[0] unless local_options_array
        options ?= {}
        options
      call_callback = (fn, args) ->
        stack.unshift todos
        todos = []
        todos.err = null
        todos.status = []
        todos.throw_if_error = true
        try
          fn.apply obj, args
        catch err
          todos = stack.shift()
          jump_to_error err
          return run()
        mtodos = todos
        todos = stack.shift()
        todos.unshift mtodos... if mtodos.length
      # parse_action = (action) ->
      call_sync = (action) ->
        options = enrich_options action.options
        todos.status.unshift undefined
        stack.unshift todos
        todos = []
        todos.err = null
        todos.status = []
        todos.throw_if_error = true
        try
          status = action.handler.apply obj, [options]
        catch err
          todos = stack.shift()
          jump_to_error err
          return run()
        mtodos = todos
        todos = stack.shift()
        todos.unshift mtodos... if mtodos.length
        todos.status.unshift status
      call_async = (action) ->
        options = enrich_options action.options
        callback = action.callback
        try
          todos.status.unshift undefined
          stack.unshift todos
          todos = []
          todos.err = null
          todos.status = []
          todos.throw_if_error = true
          status_callback = []
          status_action = []
          finish = (err) ->
            arguments.length = 2 if arguments.length is 0
            todos = stack.shift() if todos.length is 0
            todos.throw_if_error = false if err and callback
            jump_to_error err if err
            status_callback = status_callback.some (status) -> !! status
            status_action = status_action.some (status) -> !! status
            callback_args = [err, status_callback, [].slice.call(arguments)[1...]...]
            todos.status[0] = status_action and not options.shy
            call_callback callback, callback_args if callback
            return run()
            # if callback then callback(err) else run()
          wrap obj, [options, finish], (options, callback) ->
            todos.options = options
            action.handler.call obj, options, (err, status, args...) ->
              status_callback.push status
              status_action.push status unless options.shy
              setImmediate ->
                callback err, status, args...
        catch err
          todos = stack.shift()
          jump_to_error err
          run()
      jump_to_error = (err) ->
        while todos[0] and todos[0].type isnt 'then' then todos.shift()
        todos.err = err
        # return run()
      run = ->
        todo = todos.shift()
        unless todo # Nothing more to do in current queue
          throw todos.err if todos.err and todos.throw_if_error
          return
        if todo.type is 'then'
          {err, status} = todos
          status = status.some (status) -> !! status
          todos.err = null
          todos.status = []
          todos.throw_if_error = true
          todo.handler.call obj, err, status
          run()
          return
        # Call the action
        todo.options.user_args = todo.options.callback?.length > 2
        if todo.handler.length is 2 # Async style
          return call_async todo
        else # Sync style
          call_sync todo
          return run()
      properties.child = get: ->
        ->
          module.exports(obj.options)
      properties.then = get: ->
        ->
          todos.push type: 'then', handler: arguments[0]
          setImmediate run if todos.length is 1 # Activate the pump
          obj
      properties.call = get: ->
        ->
          args = [].slice.call(arguments)
          todos.push normalize_arguments args
          setImmediate run if todos.length is 1 # Activate the pump
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
              # Insert handler before callback or at the end of arguments
              args = [].slice.call(arguments)
              for arg, i in args
                if typeof arg is 'function'
                  args.splice i, 0, obj.registry[name] or registry[name]
                  break
                if i + 1 is args.length
                  args.push obj.registry[name] or registry[name]
              todos.push normalize_arguments args
              setImmediate run if todos.length is 1 # Activate the pump
              obj
      Object.defineProperty obj, 'registered', get: ->
        (name, local_only=false) ->
          global = Object.prototype.hasOwnProperty.call module.exports, name
          local = Object.prototype.hasOwnProperty.call obj, name
          if local_only then local else global or local
      Object.defineProperty obj, 'status', get: ->
        (index) ->
          if arguments.length is 0
            return stack[0].status.some (status) -> !! status
          else
            stack[0].status[Math.abs index]
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
