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
      befores = []
      afters = []
      normalize_arguments = (_arguments, type='call') ->
        multiple = false
        handler = null
        callback = null
        if typeof _arguments[0] is 'function'
          options = [{}]
        else if Array.isArray _arguments[0]
          multiple = true
          options = _arguments[0]
        else if _arguments[0] and typeof _arguments[0] is 'object'
          options = [_arguments[0]]
        else
          options = [argument: _arguments[0]]
        # for option in options
        #   option.type = type
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
        # User arguments
        if callback?.length > 2
          option.user_args = true for option in options
        type: type, options: options, multiple: multiple, handler: handler, callback: callback
      enrich_options = (user_options) ->
        global_options = obj.options
        parent_options = todos.options
        # local_options_array = Array.isArray user_options
        local_options = user_options
        # local_options = [local_options] unless local_options_array 
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
      call_ = (action) ->
        action.options = enrich_options action.options
        callback = (err, statuses, user_args) ->
          user_args.length = 2 if user_args.length is 0
          todos = stack.shift() if todos.length is 0
          jump_to_error err if err
          todos.throw_if_error = false if err and action.callback
          status_callback = statuses.some (status) -> !! status
          statuses = statuses.some (status, i) ->
            return false if action.options[i].shy
            !! status
          user_args = user_args[0] unless action.multiple
          callback_args = [err, status_callback, user_args...]
          todos.status[0] = statuses and not action.options.shy
          call_callback action.callback, callback_args if action.callback
          return run()
        todos.status.unshift undefined
        stack.unshift todos
        todos = []
        todos.err = null
        todos.status = []
        todos.throw_if_error = true
        wrap.options action.options, (err) ->
          statuses = []
          user_args = for options in action.options then []
          call_before action, (err) ->
            return next err if err
            each action.options
            .run (options, index, next) ->
              conditions.all obj, options
              , (err) ->
                statuses.push false
                next err
              , ->
                todos.options = options
                if action.handler.length is 2 # Async style
                  action.handler.call obj, options, (err, status, args...) ->
                    statuses.push status
                    for arg, i in args
                      user_args[index].push arg
                    setImmediate -> next err
                else # Sync style
                  try
                    statuses.push action.handler.call obj, options
                    stack[0].unshift todos if todos.length
                    next()
                  catch e then next e
            .then (err) ->
              callback err, statuses, user_args
      call_before = (action, callback) ->
        each befores
        .run (before, next) ->
          before.target = type: before.target if typeof before.target is 'string'
          return next() unless action.type is before.target.type
          before.handler.call obj, action.options, next
        .then callback
      jump_to_error = (err) ->
        throw err unless todos?
        while todos[0] and todos[0].type isnt 'then' then todos.shift()
        todos.err = err
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
        call_ todo
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
      properties.before = get: ->
        ->
          befores.push type: 'before', target: arguments[0], handler: arguments[1]
          obj
      properties.after = get: ->
        ->
          afters.push type: 'after', options: arguments
          obj
      properties.status = get: ->
        (index) ->
          if arguments.length is 0
            return stack[0].status.some (status) -> !! status
          else
            stack[0].status[Math.abs index]
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
              todos.push normalize_arguments args, name
              setImmediate run if todos.length is 1 # Activate the pump
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

    registry = require './misc/registry'
    do ->
      register = module.exports.register = (name, handler, api) ->
        if handler is null or handler is false
          delete registry[name] if registered name
          delete module.exports[name] if registered name
          return module.exports
        throw Error "Function already defined '#{name}'" if registered name
        registry[name] = handler unless api
        Object.defineProperty module.exports, name, 
          configurable: true
          get: -> module.exports()[name]

      registered = module.exports.registered = (name) ->
        Object.prototype.hasOwnProperty.call module.exports, name

      # Pre-register mecano internal functions
      register name, handler for name, handler of registry
      register 'before', module.exports().before, true
      register 'call', module.exports().call, true
      register 'then', module.exports().then, true

    conditions = require './misc/conditions'
    wrap = require './misc/wrap'
    each = require 'each'
