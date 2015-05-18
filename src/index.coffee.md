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
      properties = {}
      stack = []
      todos = []
      todos.err = null
      todos.changed = false
      todos.throw_if_error = true
      callid = 0
      call_callback = (fn, args) ->
        # console.log 'call_sync', args.length
        ++callid
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
        # console.log 'call_sync', args.length
        ++callid
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
      call_async = (fn, options={}, callback) ->
        # args = if args? then [args] else []
        # console.log 'call_async', args.length
        ++callid
        # On error, what shall we do:
        # - if a then is registered, jump to then and skip all actions
        # - if no then and a callback, let the callback deal with it
        # Call the user callback synchronously

        if Array.isArray options
          for t in options
            for k, v of obj.options
              t[k] = obj.options[k] if typeof t[k] is 'undefined'
        else if typeof options is 'object'
          t = options
          for k, v of obj.options
            t[k] = obj.options[k] if typeof t[k] is 'undefined'
        try
          stack.unshift todos
          todos = []
          todos.err = null
          todos.changed = false
          todos.throw_if_error = true
          finish = (err, changed) ->
            arguments[0] ?= null
            arguments[1] = !!arguments[1] unless err
            arguments.length = 2 if arguments.length is 0
            todos = stack.shift() if todos.length is 0
            todos.throw_if_error = false if err and callback
            jump_to_error err if err
            # console.log '???' if changed and not err and not options?.shy
            call_callback callback, arguments if callback
            # console.log 'changed', changed
            if changed and not err and not options?.shy then todos.changed = true 
            return run()
          # console.log options.source if options.source
          wrap obj, [options, finish], (options, callback) ->
            # console.log 'wrap pass'
            fn.call obj, options, callback
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
          # console.log 'length is ', todo[1][0].length
          if todo[1][0].length is 2 # Async style
            return call_async todo[1][0], null, null
          else # Sync style
            changed = call_sync todo[1][0], []
            # console.log '2status changed', changed
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
        # console.log todo[0]
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
