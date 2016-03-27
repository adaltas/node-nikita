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
      # listeners = {}
      stack = []
      todos = todos_create()
      befores = []
      afters = []
      depth = 0
      killed = false
      obj.options.domain =  domain.create() if obj.options.domain is true
      domain_on_error = (err) ->
        err.message = "Invalid State Error [#{err.message}]"
        handle_multiple_call err
      obj.options.domain?.on 'error', domain_on_error
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
            opts.log ?= (log) -> process.stdout.write "[#{log.level} #{log.time}] #{log.message}\n"
            opts.stdout ?= process.stdout
            opts.stderr ?= process.stderr
        options
      enrich_options = (user_options) ->
        user_options.enriched = true
        global_options = obj.options
        parent_options = todos.options
        local_options = user_options
        options = {}
        for k, v of local_options then options[k] = local_options[k]
        for k, v of parent_options
          options[k] = v if options[k] is undefined and k in obj.propagated_options
        for k, v of global_options
          options[k] = v if options[k] is undefined
        _log = options.log unless options.log?.dont
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
          _log? log
          obj.emit? log.type, log
        options.log.dont = true
        options
      call_callback = (fn, args) ->
        stack.unshift todos
        todos = todos_create()
        try
          fn.apply obj, args
        catch err
          todos = stack.shift()
          jump_to_error err
          args[0] = err
          return run()
        mtodos = todos
        todos = stack.shift()
        todos.unshift mtodos... if mtodos.length
      handle_multiple_call = (err) ->
        killed = true
        todos = stack.shift() while stack.length
        jump_to_error err
        run()
      jump_to_error = (err) ->        
        # throw err unless todos?
        while todos[0] and todos[0].type isnt 'then' then todos.shift()
        todos.err = err
      _run_ = ->
        if obj.options.domain
        then obj.options.domain.run run
        else run()
      run = (options, callback) ->
        options = todos.shift() unless options
        unless options # Nothing more to do in current queue
          if stack.length is 0
            obj.options.domain?.removeListener 'error', domain_on_error
          if callback
            callback todos.err
          else
            throw todos.err if stack.length is 0 and todos.err and todos.throw_if_error
          return
        options = enrich_options options
        if options.type is 'then'
          {err, status} = todos
          status = status.some (status) -> not status.shy and !!status.value
          todos_reset todos
          options.handler?.call obj, err, status
          run()
          return
        return if killed
        if options.type is 'end'
          return conditions.all obj, options
          , (err) ->
            callback err if callback
            run()
          , ->
            while todos[0] and todos[0].type isnt 'then' then todos.shift()
            callback err if callback
            run()
        depth++ if options.header
        options.log message: options.header, type: 'header', depth: depth if options.header
        todos.status.unshift shy: options.shy, value: undefined
        stack.unshift todos
        todos = todos_create()
        wrap.options options, (err) ->
          copy = {}
          for k, v of options
            copy[k] = v
          options = copy
          options_handler = options.handler
          options.handler = undefined
          options_callback = options.callback
          options.callback = undefined
          do_intercept_before = ->
            return do_conditions() if options.intercept_before
            each befores
            .call (before, next) ->
              for k, v of before
                continue if k is 'handler'
                return next() unless v is options[k]
              opts = intercept_before: true
              for k, v of before
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              run opts, next
            .error (err) -> do_callback [err]
            .then do_conditions
          do_conditions = ->
            conditions.all obj, options
            , (err) ->
              do_callback [err]
            , ->
              for k, v of options # Remove conditions from options
                delete options[k] if /^if.*/.test(k) or /^unless.*/.test(k)
              todos.options = options
              do_handler()
          do_handler = ->
            called = false
            try
              if options_handler.length is 2 # Async style
                options_handler.call obj, options, ->
                  return if killed
                  return handle_multiple_call Error 'Multiple call detected' if called
                  called = true
                  args = [].slice.call(arguments, 0)
                  setImmediate -> 
                    do_intercept_after args
              else # Sync style
                options_handler.call obj, options
                return if killed
                return handle_multiple_call Error 'Multiple call detected' if called
                called = true
                status_sync = false
                wait_children = ->
                  unless todos.length
                    return setImmediate ->
                      do_intercept_after [null, status_sync]
                  loptions = todos.shift()
                  run loptions, (err, status) ->
                    return do_intercept_after [err] if err
                    # Discover status of all unshy children
                    status_sync = true if status and not loptions.shy
                    wait_children()
                wait_children()
            catch err
              todos = []
              do_intercept_after [err]
          do_intercept_after = (args, callback) ->
            return do_callback args if options.intercept_after
            each afters
            .call (after, next) ->
              for k, v of after
                continue if k is 'handler'
                return next() unless v is options[k]
              opts = intercept_after: true
              for k, v of after
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              opts.callback_arguments = args
              run opts, next
            .error (err) -> do_callback [err]
            .then -> do_callback args
          do_callback = (args) ->
            return if killed
            args[0] = undefined unless args[0] # Error is undefined and not null or false
            args[1] = !!args[1] # Status is a boolean, error or not
            todos = stack.shift() if todos.length is 0
            jump_to_error args[0] if args[0] and not options.relax
            todos.throw_if_error = false if args[0] and options_callback
            todos.status[0].value = args[1]
            call_callback options_callback, args if options_callback
            args[0] = null if options.relax
            depth-- if options.header
            callback args[0], args[1] if callback
            run()
          do_intercept_before()
      properties.child = get: -> ->
        module.exports(obj.options)
      properties.then = get: -> ->
        todos.push type: 'then', handler: arguments[0]
        setImmediate _run_ if todos.length is 1 # Activate the pump
        obj
      properties.end = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'end'
        todos.push opts for opts in options
        setImmediate _run_ if todos.length is options.length # Activate the pump
        obj
      properties.call = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'call'
        for opts in options
          throw Error 'Missing handler option' unless opts.handler
          throw Error "Handler not a function, got '#{opts.handler}'" unless typeof opts.handler is 'function'        
        todos.push opts for opts in options
        setImmediate _run_ if todos.length is options.length # Activate the pump
        obj
      properties.before = get: -> ->
        arguments[0] = type: arguments[0] if typeof arguments[0] is 'string'
        options = normalize_options arguments, null, false
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          befores.push opts
        obj
      properties.after = get: -> ->
        arguments[0] = type: arguments[0] if typeof arguments[0] is 'string'
        options = normalize_options arguments, null, false
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          afters.push opts
        obj
      properties.status = get: -> (index) ->
        if arguments.length is 0
          return stack[0].status.some (status) -> not status.shy and !!status.value
        else if index is false
          value = stack[0].status.some (status) -> not status.shy and !!status.value
          status.value = false for status in stack[0].status
          return value
        else if index is true
          value = stack[0].status.some (status) -> not status.shy and !!status.value
          status.value = true for status in stack[0].status
          return value
        else
          stack[0].status[Math.abs index]?.value
      proto = Object.defineProperties obj, properties
      # Register function
      Object.defineProperty obj, 'register', get: -> (name, handler) ->
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
        Object.defineProperty obj, name, configurable: true, get: -> ->
          # Insert handler before callback or at the end of arguments
          args = [].slice.call(arguments)
          args.unshift obj.registry[name]
          options = normalize_options args, name
          todos.push opts for opts in options
          setImmediate _run_ if todos.length is options.length # Activate the pump
          obj
      Object.defineProperty obj, 'registered', get: -> (name, local_only=false) ->
        global = Object.prototype.hasOwnProperty.call module.exports, name
        local = Object.prototype.hasOwnProperty.call obj, name
        if local_only then local else global or local
      obj.register name, handler for name, handler of registry
      obj

    module.exports.propagated_options = ['ssh', 'log', 'stdout', 'stderr', 'debug']

## Helper functions

    todos_create = ->
      todos = []
      todos_reset todos
      todos
    todos_reset = (todos) ->
      todos.err = null
      todos.status = []
      todos.throw_if_error = true

## Register functions

Register a new function available when requiring mecano and inside any mecano
instance. 

You can also un-register a existing function by passing "null" or "false" as
the second argument. It will return "true" if the function is un-registered or
"false" if there was nothing to do because the function wasn't already
registered.

    domain = require 'domain'
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
