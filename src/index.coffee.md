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
        obj = new EventEmitter
        obj.options = arguments[0]
      else
        obj = new EventEmitter
        obj.options = {}
      obj.registry ?= {}
      obj.propagated_options ?= []
      for option in module.exports.propagated_options then obj.propagated_options.push option
      store = {}
      properties = {}
      listeners = {}
      stack = []
      todos = []
      todos.err = null
      todos.status = []
      todos.throw_if_error = true
      befores = []
      afters = []
      depth = 0
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
          else
            arg = argument: arg if typeof arg isnt 'object' and arg isnt null
            if options.length is 0
              options.push arg
            else for opts in options
              for k, v of arg then opts[k] = v
        return options if options.length is 0 and empty
        options.push {} if options.length is 0
        if options.length and options.filter( (opts) -> not opts.handler ).length is 0
          callback = handler
          handler = null
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
        emit = (log) ->
          listener.call null, log for listener in listeners[log.type]?
        _log = options.log or (->)
        options.log = (log) ->
          log = message: log if typeof log is 'string'
          log.level ?= 'INFO'
          log.time ?= Date.now()
          log.module ?= undefined
          log.header_depth ?= depth
          log.total_depth ?= stack.length
          log.type ?= 'text'
          args = if 1 <= arguments.length then [].slice.call(arguments, 0) else []
          stackTrace = require 'stack-trace'
          path = require 'path'
          frame = stackTrace.get()[1]
          file = path.basename(frame.getFileName())
          line = frame.getLineNumber()
          method = frame.getFunctionName()
          log.file = file
          log.line = line
          args.unshift("" + file + ":" + line + " in " + method + "()");
          _log log
          obj.emit? log.type, log
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
      intercept_after = (target_options, args, callback) ->
        return callback() if target_options.intercept_after
        each afters
        .run (after, next) ->
          for k, v of after
            continue if k is 'handler'
            return next() unless v is target_options[k]
          options = intercept_after: true
          for k, v of after
            options[k] = v
          for k, v of target_options
            continue if k in ['handler', 'callback']
            options[k] ?= v
          options.callback_arguments = args
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
          if callback
            callback todos.err
          else
            throw todos.err if stack.length is 0 and todos.err and todos.throw_if_error
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
        depth++ if options.header
        options.log message: options.header, type: 'header', depth: depth if options.header
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
          copy = {}
          for k, v of options
            copy[k] = v
          options = copy
          # Before interception
          intercept_before options, (err) ->
            exec_callback = (args) ->
              intercept_after options, args, (err) ->
                return exec_callback [err] if err
                args[0] = undefined unless args[0]
                args[1] = !!args[1]
                # intercept_after options, err, (err) ->
                # throw Error 'Invalid state' unless todos.length is 0
                todos = stack.shift() if todos.length is 0
                jump_to_error args[0] if args[0] and not options.relax
                todos.throw_if_error = false if args[0] and options_callback
                todos.status[0] = args[1] and not options.shy
                call_callback options_callback, args if options_callback
                args[0] = null if options.relax
                depth-- if options.header
                callback args[0], args[1] if callback
                run()
            return exec_callback [err] if err
            # options_header = options.header
            # options.header = undefined
            options_handler = options.handler
            options.handler = undefined
            options_callback = options.callback
            options.callback = undefined
            conditions.all obj, options
            , (err) ->
              exec_callback [err]
            , ->
              # Remove conditions from options
              for k, v of options
                delete options[k] if /^if.*/.test(k) or /^unless.*/.test(k)
              todos.options = options
              try
                if options_handler.length is 2 # Async style
                  options_handler.call obj, options, ->
                    args = [].slice.call(arguments, 0)
                    setImmediate -> exec_callback args
                else # Sync style
                  options_handler.call obj, options
                  status_sync = false
                  wait_children = ->
                    unless todos.length
                      return setImmediate ->
                        exec_callback [null, status_sync]
                    run todos.shift(), (err, status) ->
                      return exec_callback [err] if err
                      status_sync = true if status
                      wait_children()
                  wait_children()
              catch err then exec_callback [err]
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
          for opts in options
            throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
            befores.push opts
          obj
      properties.after = get: ->
        ->
          arguments[0] = type: arguments[0] if typeof arguments[0] is 'string'
          options = normalize_options arguments, null, false
          for opts in options
            throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
            afters.push opts
          obj
      # properties.on = get: ->
      #   ->
      #     listeners[arguments[0]] ?= []
      #     listeners[arguments[0]].push arguments[1]
      #     obj
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

    {EventEmitter} = require 'events'
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
      register 'after', module.exports().after, true
      register 'then', module.exports().then, true
      # register 'on', module.exports().on, true
      module.exports.on = ->
        obj = module.exports()
        o = obj.on.apply obj, arguments

    each = require 'each'
    conditions = require './misc/conditions'
    wrap = require './misc/wrap'
