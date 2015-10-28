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
      store = {}
      properties = {}
      stack = []
      todos = []
      todos.err = null
      todos.status = []
      todos.throw_if_error = true
      befores = []
      afters = []
      normalize_options = (_arguments, type, enrich=true) ->
        empty = false
        handler = null
        callback = null
        options = []
        for arg in _arguments
          if typeof arg is 'function'
            unless handler then handler = arg
            else unless callback then callback = arg
            else throw Error "Invalid third function argument"
          else if Array.isArray arg
            empty = true if arg.length is 0
            for a in arg
              a = argument: a unless typeof a is 'object' and not Array.isArray(a) and a isnt null
              options.push a
          else #if typeof arg is 'object'
            arg = argument: arg if typeof arg isnt 'object' and arg isnt null
            if options.length is 0
              options.push arg
            else for opts in options
              for k, v of arg then opts[k] = v
          # else
          #   options.push argument: arg
        return options if options.length is 0 and empty
        options.push {} if options.length is 0
        if options.length and options.filter( (opts) -> not opts.handler ).length is 0
          callback = handler
          handler = null
        # for opts, i in options
        #   continue if typeof arg is 'function'
        #   continue if Array.isArray arg
        #   continue if typeof arg is 'object' and arg isnt null
        #   options[i] = argument: opts
        for opts, i in options
          # Clone
          options[i] = {}
          options[i][k] = v for k, v of opts
          opts = options[i]
          # Enrich
          opts.type = type if type
          opts.handler ?= handler if handler
          opts.callback ?= callback if callback
          opts.user_args = true if enrich and opts.callback?.length > 2
          opts.store ?= store if enrich and store
          if opts.debug
            opts.log ?= (msg) -> process.stdout.write "#{msg}\n"
            opts.stdout ?= process.stdout
            opts.stderr ?= process.stderr
        options
      enrich_options = (user_options) ->
        global_options = obj.options
        parent_options = todos.options
        local_options = user_options
        options = {}
        for k, v of local_options then options[k] = local_options[k]
        for k, v of parent_options
          options[k] = v if options[k] is undefined and k in obj.propagated_options
        for k, v of global_options
          options[k] = v if options[k] is undefined
        options
      intercept_before = (target_options, callback) ->
        return callback() if target_options.intercept_before
        each befores
        .run (before, next) ->
          for k, v of before
            continue if k is 'handler'
            return next() unless v is target_options[k]
          options = intercept_before: true
          for k, v of before
            options[k] = v
          for k, v of target_options
            continue if k in ['handler', 'callback']
            options[k] ?= v
          run options, next
        .then callback
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
      jump_to_error = (err) ->
        throw err unless todos?
        while todos[0] and todos[0].type isnt 'then' then todos.shift()
        todos.err = err
      run = (options, callback) ->
        options = todos.shift() unless options
        unless options # Nothing more to do in current queue
          throw todos.err if todos.err and todos.throw_if_error
          # if stack.length
          #   stack.shift()
          #   run()
          return
        if options.type is 'then'
          {err, status} = todos
          status = status.some (status) -> !! status
          todos.err = null
          todos.status = []
          todos.throw_if_error = true
          options.handler?.call obj, err, status
          run()
          return
        options = enrich_options options
        if options.type is 'end'
          return conditions.all obj, options
          , (err) ->
            callback err if callback
            return run()
          , ->
            while todos[0] and todos[0].type isnt 'then' then todos.shift()
            callback err if callback
            return run()
        todos.status.unshift undefined
        stack.unshift todos
        todos = []
        todos.err = null
        todos.status = []
        todos.throw_if_error = true
        wrap.options options, (err) ->
          status = false
          user_args = []
          throw_error = undefined
          copy = {}
          for k, v of options
            copy[k] = v
          options = copy
          # Before interception
          intercept_before options, (err) ->
            exec_callback = (err) ->
              user_args.length = 2 if user_args.length is 0
              todos = stack.shift() if todos.length is 0
              jump_to_error err if err and not options.relax
              todos.throw_if_error = false if err and options_callback
              callback_args = [err, status, user_args...]
              todos.status[0] = status and not options.shy
              call_callback options_callback, callback_args if options_callback
              err = null if options.relax
              callback err, status if callback
              return run()
            return exec_callback err if err
            options_handler = options.handler
            options.handler = undefined
            options_callback = options.callback
            options.callback = undefined
            conditions.all obj, options
            , (err) ->
              exec_callback err
            , ->
              # Remove conditions from options
              for k, v of options
                delete options[k] if /^if.*/.test(k) or /^not_if.*/.test(k)
              todos.options = options
              try
                if options_handler.length is 2 # Async style
                  options_handler.call obj, options, (err, _status, args...) ->
                    status = true if _status
                    for arg, i in args
                      user_args.push arg
                    setImmediate -> exec_callback err
                else # Sync style
                  options_handler.call obj, options
                  status_sync = false
                  wait_children = ->
                    unless todos.length
                      status = status_sync
                      return setImmediate exec_callback
                    run todos.shift(), (err, status) ->
                      return exec_callback err if err
                      status_sync = true if status
                      wait_children()
                  wait_children()
              catch e then exec_callback e
      properties.child = get: ->
        ->
          module.exports(obj.options)
      properties.then = get: ->
        ->
          todos.push type: 'then', handler: arguments[0]
          setImmediate run if todos.length is 1 # Activate the pump
          obj
      properties.end = get: ->
        ->
          args = [].slice.call(arguments)
          options = normalize_options args, 'end'
          todos.push opts for opts in options
          setImmediate run if todos.length is options.length # Activate the pump
          obj
      properties.call = get: ->
        ->
          args = [].slice.call(arguments)
          options = normalize_options args, 'call'
          todos.push opts for opts in options
          setImmediate run if todos.length is options.length # Activate the pump
          obj
      properties.before = get: ->
        ->
          arguments[0] = type: arguments[0] if typeof arguments[0] is 'string'
          options = normalize_options arguments, null, false
          befores.push opts for opts in options
          obj
          # event = arguments[0]
          # if typeof event is 'string'
          #   event = type: event
          # options = normalize_options [arguments[1]], 'before'
          # opts.event = event for opts in options
          # befores.push opts for opts in options
          # obj
      properties.after = get: ->
        ->
          throw Error "look at before, doesnt seem ready yet"
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
              args.unshift obj.registry[name]
              options = normalize_options args, name
              todos.push opts for opts in options
              setImmediate run if todos.length is options.length # Activate the pump
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
      register 'end', module.exports().end, true
      register 'call', module.exports().call, true
      register 'before', module.exports().before, true
      register 'after', module.exports().before, true
      register 'then', module.exports().then, true

    conditions = require './misc/conditions'
    wrap = require './misc/wrap'
    each = require 'each'
