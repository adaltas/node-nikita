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
      normalize_arguments = (_arguments, type='call') ->
        multiple = false
        handler = null
        callback = null
        if typeof _arguments[0] is 'function'
          options = [{}]
        else if Array.isArray _arguments[0]
          multiple = true
          options = _arguments[0]
          options = for opts in _arguments[0]
            copy = {}
            for k, v of opts
              copy[k] = v
            copy
        else if _arguments[0] and typeof _arguments[0] is 'object'
          arg = _arguments[0]
          options = {}
          options[k] = v for k, v of arg
          options = [options]
        else
          options = [argument: _arguments[0]]
        found_handler = options.every (opts) -> !!opts.handler
        for arg, i in _arguments
          continue if i is 0 and typeof arg isnt 'function'
          if typeof arg is 'function'
            if handler or (found_handler and options.length isnt 0)
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
          opts.user_args = true for opts in options
        opts.store ?= store for opts in options
        opts.type ?= type for opts in options
        # options = [handler: handler] if options.length is 0 and handler
        opts.handler ?= handler for opts in options if handler
        for opts in options
          if opts.debug
            opts.log ?= (msg) -> process.stdout.write "#{msg}\n"
            opts.stdout ?= process.stdout
            opts.stderr ?= process.stderr
        type: type, options: options, multiple: multiple, callback: callback
      enrich_options = (user_options) ->
        global_options = obj.options
        parent_options = todos.options
        local_options = user_options
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
      intercept_before = (options, callback) ->
        return callback() if options.intercept_before
        each befores
        .run (before, next) ->
          # before.target = type: before.target if typeof before.target is 'string'
          # for k, v in before
          #   return next() unless before[k] isnt options[k]
          # return next() unless options.type is before.target.type
          for k, v of before.event
            return next() unless v is options[k]
          # return next() unless options.type is before.event.type
          action = {}
          for k, v of before
            action[k] = v
          action.options = [{intercept_before: true}]
          for k, v of options
            if k is 'handler'
              action.options[0][k] = before.options[0][k]
            else
              action.options[0][k] = v
          run action, next
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
      run = (action, callback) ->
        action = todos.shift() unless action
        unless action # Nothing more to do in current queue
          throw todos.err if todos.err and todos.throw_if_error
          # if stack.length
          #   stack.shift()
          #   run()
          return
        if action.type is 'then'
          {err, status} = todos
          status = status.some (status) -> !! status
          todos.err = null
          todos.status = []
          todos.throw_if_error = true
          action.handler?.call obj, err, status # shall be normalized and be `option.handler?.call... for option in action.options`
          run()
          return
        # Call the action
        run_callback = (err, throw_error, statuses, user_args) ->
          user_args.length = 2 if user_args.length is 0
          todos = stack.shift() if todos.length is 0
          jump_to_error err if err and throw_error
          todos.throw_if_error = false if err and action.callback
          status_callback = statuses.some (status) -> !! status
          statuses = statuses.some (status, i) ->
            return false if action.options[i].shy
            !! status
          user_args = user_args[0] unless action.multiple
          callback_args = [err, status_callback, user_args...]
          todos.status[0] = statuses and not action.options.shy
          call_callback action.callback, callback_args if action.callback
          err = null if action.options[0]?.relax
          callback err, statuses if callback
          return run()
        action.options = enrich_options action.options
        if action.type is 'end'
          return conditions.all obj, action.options[0]
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
        wrap.options action.options, (err) ->
          statuses = []
          user_args = for options in action.options then []
          throw_error = undefined
          each action.options
          .run (options, index, next) ->
            # Clone options
            copy = {}
            for k, v of options
              copy[k] = v
            options = copy
            # Before interception
            intercept_before options, (err) ->
              relax = (e) ->
                throw_error = true if e and not options.relax
                next e
              return relax err if err
              handler = options.handler
              options.handler = undefined
              conditions.all obj, options
              , (err) ->
                statuses.push false
                relax err
              , ->
                # Remove conditions from options
                for k, v of options
                  delete options[k] if /^if.*/.test(k) or /^not_if.*/.test(k)
                todos.options = options
                try
                  if handler.length is 2 # Async style
                    handler.call obj, options, (err, status, args...) ->
                      statuses.push status
                      for arg, i in args
                        user_args[index].push arg
                      setImmediate -> relax err
                  else # Sync style
                    # statuses.push handler.call obj, options
                    handler.call obj, options
                    status_sync = false
                    wait_children = ->
                      unless todos.length
                        statuses.push status_sync
                        return setImmediate relax
                      run todos.shift(), (err, status) ->
                        return relax err if err
                        status_sync = true if status
                        wait_children()
                    wait_children()
                    # stack[0].unshift todos... if todos.length
                    # todos = []
                    # setImmediate relax
                catch e then relax e
          .then (err) ->
            run_callback err, throw_error, statuses, user_args
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
          todos.push normalize_arguments args, 'end'
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

          event = arguments[0]
          if typeof event is 'string'
            event = type: event
          action = normalize_arguments [arguments[1]], 'before'
          action.event = event
          befores.push action
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
      register 'end', module.exports().end, true
      register 'call', module.exports().call, true
      register 'before', module.exports().before, true
      register 'after', module.exports().before, true
      register 'then', module.exports().then, true

    conditions = require './misc/conditions'
    wrap = require './misc/wrap'
    each = require 'each'
