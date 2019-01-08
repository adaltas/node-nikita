
# Nikita Session

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
      obj.store ?= {}
      # Internal state
      state = {}
      state.properties = {}
      state.parent_levels = []
      state.current_level = state_create_level()
      state.befores = []
      state.afters = []
      state.once = {}
      state.killed = false
      state.index_counter = 0
      # Domain
      obj.options.domain =  domain.create() if obj.options.domain is true
      domain_on_error = (err) ->
        err.message = "Invalid State Error [#{err.message}]"
        handle_multiple_call err
      obj.options.domain?.on 'error', domain_on_error
      # Proxify
      proxy = new Proxy obj,
        has: (target, name) ->
          console.warns 'proxy has is being called', name
        apply: (target, thisArg, argumentsList) ->
          console.warn 'apply'
        get: (target, name) ->
          return target[name] if obj[name]?
          return target[name] if name in ['domain', '_events', '_maxListeners', 'internal']
          proxy.action = []
          proxy.action.push name
          if not obj.registry.registered(proxy.action, parent: true) and not registry.registered(proxy.action, parent: true)
            proxy.action = []
            return undefined
          get_proxy_builder = ->
            builder = ->
              args = [].slice.call(arguments)
              options = normalize_options args, proxy.action
              proxy.action = []
              {get, values} = handle_get proxy, options
              return values if get
              state.current_level.push opts for opts in options
              setImmediate _run_ if state.current_level.length is options.length # Activate the pump
              proxy
            new Proxy builder,
              get: (target, name) ->
                return target[name] if target[name]?
                proxy.action.push name
                if not obj.registry.registered(proxy.action, parent: true) and not registry.registered(proxy.action, parent: true)
                  proxy.action = []
                  return undefined
                get_proxy_builder()
          get_proxy_builder()
      obj.internal = {}
      obj.internal.options = (_arguments, action_name, params={}) ->
        params.enrich ?= true
        # Does the actions require a handler
        params.handler ?= false
        _arguments = [{}] if _arguments.length is 0
        # Convert every argument to an array
        for args, i in _arguments
          _arguments[i] = [args] unless Array.isArray args
        # Get middleware
        middleware = obj.registry.get(action_name) or registry.get(action_name) if Array.isArray(action_name)
        # Multiply arguments
        actions = null
        for __arguments, i in _arguments
          newactions = for __argument, j in __arguments
            if i is 0
              [[middleware, __argument]]
            else
              for action, i in actions
                [action..., __argument]
          actions = array.flatten newactions, 0
        # Load module
        unless middleware
          for action in actions
            middleware = null
            for option in action
              if typeof option is 'string'
                middleware = option
                middleware = path.resolve process.cwd(), option if option.substr(0, 1) is '.'
                middleware = require.main.require middleware
            action.unshift middleware if middleware
        # Build actions
        actions = for action in actions
          newaction = {}
          for opt in action
            continue unless action?
            if typeof opt is 'string'
              if not newaction.argument
                opt = argument: opt
              else
                throw Error 'Invalid option: encountered a string while argument is already defined'
            if typeof opt is 'function'
              # todo: handler could be registed later by an external module,
              # in such case, the user provided function should be interpreted
              # as a callback
              if not newaction.handler
                opt = handler: opt
              else if not newaction.callback
                opt = callback: opt
              else
                throw Error 'Invalid option: encountered a function while both handler and callback options are defined.'
            if typeof opt isnt 'object'
              opt = argument: opt
            for k, v of opt
              continue if newaction[k] isnt undefined and v is undefined
              newaction[k] = v
          newaction
        # Normalize
        actions = for action in actions
          # Enrich
          action.action = action_name if action_name
          action.action = [action.action] unless Array.isArray action.action
          action.user_args = true if params.enrich and action.callback?.length > 2 # Doesnt seem to be used anywhere
          action.once = ['handler'] if action.once is true
          delete action.once if action.once is false
          action.once = action.once.sort() if Array.isArray action.once
          action.once = action.once.sort() if Array.isArray action.once
          # action.sleep ?= 3000 # Wait 3s between retry
          # action.retry ?= 0
          # action.disabled ?= false
          # action.status ?= true
          # action.depth = state.parent_levels.length + 1
          # throw Error 'Incompatible Options: status "false" implies shy "true"' if action.status is false and action.shy is false # Room for argument, leave it strict for now until we come accross a usecase justifying it.
          # action.shy ?= true if action.status is false
          # action.shy ?= false
          # Validation
          if params.handler
            throw Error 'Missing handler option' unless action.handler
            throw Error "Invalid Handler: expect a function, got '#{action.handler}'" unless typeof action.handler is 'function'
          # jump_to_error Error "Invalid options sleep, got #{JSON.stringify action.sleep}" unless typeof action.sleep is 'number' and action.sleep >= 0
          action
        actions
      normalize_options = obj.internal.options
      enrich_options = (options_action) ->
        options_session = obj.options
        options_session.cascade ?= {}
        options_parent = state.current_level.options
        options = {}
        options.parent = options_parent
        # Merge cascade action options with default session options
        options.cascade = {...module.exports.cascade, ...options_session.cascade, ...options_action.cascade}
        # Copy initial options
        for k, v of options_action
          continue if k is 'cascade'
          options[k] = options_action[k]
        # Merge parent cascaded options
        for k, v of options_parent
          continue unless options.cascade[k] is true
          options[k] = v if options[k] is undefined
        # Merge action options with default session options 
        for k, v of options_session
          continue if k is 'cascade'
          options[k] = v if options[k] is undefined
        # Build headers option
        headers = []
        push_headers = (options) ->
          headers.push options.header if options.header
          push_headers options.parent if options.parent
        push_headers options
        options.headers = headers.reverse()
        # Default values
        options.sleep ?= 3000 # Wait 3s between retry
        options.retry ?= 0
        options.disabled ?= false
        options.status ?= true
        options.depth = if options.depth? then options.depth else (options.parent?.depth or 0) + 1
        # throw Error 'Incompatible Options: status "false" implies shy "true"' if options.status is false and options.shy is false # Room for argument, leave it strict for now until we come accross a usecase justifying it.
        # options.shy ?= true if options.status is false
        options.shy ?= false
        # Goodies
        if options.source and match = /~($|\/.*)/.exec options.source
          unless obj.store['nikita:ssh:connection']
          then options.source = path.join process.env.HOME, match[1]
          else options.source = path.posix.join '.', match[1]
        if options.target and match = /~($|\/.*)/.exec options.target
          unless obj.store['nikita:ssh:connection']
          then options.target = path.join process.env.HOME, match[1]
          else options.target = path.posix.join '.', match[1]
        options
      handle_get = (proxy, options) ->
        return get: false unless options.length is 1
        options = options[0]
        return get: false unless options.get is true
        options = enrich_options options
        opts = options_filter_cascade options
        values = options.handler.call proxy, options: opts, options.callback
        get: true, values: values
      options_filter_cascade = (options) ->
        opts = {}
        for k, v of options
          continue if options.cascade[k] is false
          opts[k] = v
        opts
      call_callback = (fn, args) ->
        state.parent_levels.unshift state.current_level
        state.current_level = state_create_level()
        try
          fn.apply proxy, args
        catch err
          state.current_level = state.parent_levels.shift()
          jump_to_error err
          args[0] = err
          return run()
        mtodos = state.current_level
        state.current_level = state.parent_levels.shift()
        state.current_level.unshift mtodos... if mtodos.length
      handle_multiple_call = (err) ->
        state.killed = true
        state.current_level = state.parent_levels.shift() while state.parent_levels.length
        jump_to_error err
        run()
      jump_to_error = (err) ->
        while state.current_level[0] and state.current_level[0].action not in ['catch', 'next', 'promise'] then state.current_level.shift()
        state.current_level.err = err
      _run_ = ->
        if obj.options.domain
        then obj.options.domain.run run
        else run()
      run = (options, callback) ->
        options = state.current_level.shift() unless options
        # Nothing more to do in current queue
        unless options
          obj.options.domain?.removeListener 'error', domain_on_error
          # Run is called with a callback
          if callback
            callback state.current_level.err if callback
            return
          else
            if not state.killed and state.parent_levels.length is 0 and state.current_level.err and state.current_level.throw_if_error
              obj.emit 'error', state.current_level.err
              throw state.current_level.err unless obj.listenerCount() is 0
          if state.parent_levels.length is 0
            obj.emit 'end', level: 'INFO' unless state.current_level.err
          return
        options_original = options
        options_parent = state.current_level.options
        obj.cascade = {...obj.options.cascade, ...module.exports.cascade}
        for k, v of options_parent
          options_original[k] = v if options_original[k] is undefined and obj.cascade[k] is true
        options.original = options_original
        if options.action is 'next'
          {err, status} = state.current_level
          status = status.some (status) -> not status.shy and status.value
          options.handler?.call proxy, err, {status: status}
          state_reset_level state.current_level
          run()
          return
        if options.action is 'promise'
          {err, status} = state.current_level
          status = status.some (status) -> not status.shy and status.value
          options.handler?.call proxy, err, status
          unless err
          then options.deferred.resolve status
          else options.deferred.reject err
          state_reset_level state.current_level
          return
        return if state.killed
        if array.compare options.action, ['end']
          return conditions.all proxy, options: options
          , ->
            while state.current_level[0] and state.current_level[0].action not in ['next', 'promise'] then state.current_level.shift()
            callback err, {} if callback
            run()
          , (err) ->
            callback err, {} if callback
            run()
        options = enrich_options options
        index = state.index_counter++
        state.current_level.status.unshift shy: options.shy, value: undefined
        state.parent_levels.unshift state.current_level
        state.current_level = state_create_level()
        state.current_level.options = options
        proxy.log message: options.header, type: 'header', index: index, headers: options.headers if options.header
        do () ->
          do_options = ->
            try
              # Validation
              throw Error "Invalid options sleep, got #{JSON.stringify options.sleep}" unless typeof options.sleep is 'number' and options.sleep >= 0
            catch err
              do_callback [err, status: false]
              return
            wrap.options options, (err) ->
              do_disabled()
          do_disabled = ->
            unless options.disabled
              proxy.log type: 'lifecycle', message: 'disabled_false', level: 'DEBUG', index: index, error: null, status: false
              do_once()
            else
              proxy.log type: 'lifecycle', message: 'disabled_true', level: 'INFO', index: index, error: null, status: false
              do_callback [null, status: false]
          do_once = ->
            hashme = (value) ->
              if typeof value is 'string'
                value = "string:#{string.hash value}"
              else if typeof value is 'boolean'
                value = "boolean:#{value}"
              else if typeof value is 'function'
                value = "function:#{string.hash value.toString()}"
              else if value is undefined or value is null
                value = 'null'
              else if Array.isArray value
                value = 'array:' + value.sort().map((value) -> hashme value).join ':'
              else if typeof value is 'object'
                value = 'object'
              else throw Error "Invalid data type: #{JSON.stringify value}"
              value
            if options.once
              if typeof options.once is 'string'
                hash = string.hash options.once
              else if Array.isArray options.once
                hash = string.hash options.once.map((k) -> hashme options[k]).join '|'
              else
                throw Error "Invalid Option 'once': #{JSON.stringify options.once} must be a string or an array of string"
              return do_callback [null, status: false] if state.once[hash]
              state.once[hash] = true
            do_options_before()
          do_options_before = ->
            return do_intercept_before() if options.options_before
            options.before ?= []
            options.before = [options.before] unless Array.isArray options.before
            each options.before
            .call (before, next) ->
              before = normalize_options [before], 'call', enrich: false
              before = before[0]
              opts = options_before: true
              for k, v of before
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              run opts, next
            .error (err) -> do_callback [err, status: false]
            .next do_intercept_before
          do_intercept_before = ->
            return do_conditions() if options.intercepting
            each state.befores
            .call (before, next) ->
              for k, v of before then switch k
                when 'handler' then continue
                when 'action' then return next() unless array.compare v, options[k]
                else return next() unless v is options[k]
              opts = intercepting: true
              for k, v of before
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              run opts, next
            .error (err) -> do_callback [err, status: false]
            .next do_conditions
          do_conditions = ->
            conditions.all proxy, options: options
            , ->
              for k, v of options # Remove conditions from options
                delete options[k] if /^if.*/.test(k) or /^unless.*/.test(k)
              proxy.log type: 'lifecycle', message: 'conditions_passed', index: index, error: null, status: false
              do_handler()
            , (err) ->
              proxy.log type: 'lifecycle', message: 'conditions_failed', index: index, error: err, status: false
              do_callback [err, status: false]
          options.attempt = -1
          do_handler = ->
            options.attempt++
            do_next = ([err, args]) ->
              options.handler = options_handler
              options.callback = options_callback
              if err and err not instanceof Error
                err = Error 'First argument not a valid error'
                arguments[0][0] = err
                arguments[0][1] ?= {}
                arguments[0][1].status ?= false
              else
                if typeof args is 'boolean' then arguments[0][1] = {status: args}
                else if not args then arguments[0][1] = { status: false }
                else if typeof args isnt 'object' then arguments[0][0] = Error "Invalid Argument: expect an object or a boolean, got #{JSON.stringify args}"
                else arguments[0][1].status ?= false
              proxy.log message: err.message, level: 'ERROR', index: index, module: 'nikita' if err
              if err and ( options.retry is true or options.attempt < options.retry - 1 )
                proxy.log message: "Retry on error, attempt #{options.attempt+1}", level: 'WARN', index: index, module: 'nikita'
                return setTimeout do_handler, options.sleep
              do_intercept_after arguments...
            options.handler ?= obj.registry.get(options.action)?.handler or registry.get(options.action)?.handler
            return handle_multiple_call Error "Unregistered Middleware: #{options.action.join('.')}" unless options.handler
            options_handler = options.handler
            options_handler_length = options.handler.length
            options.handler = undefined
            options_callback = options.callback
            options.callback = undefined
            called = false
            try
              # Clone and filter cascaded options
              opts = options_filter_cascade options
              # Handle deprecation
              options_handler = ( (options_handler) ->
                util.deprecate ->
                  options_handler.apply @, arguments
                , if options.deprecate is true
                then "#{options.action.join '/'} is deprecated"
                else "#{options.action.join '/'} is deprecated, use #{options.deprecate}"
              )(options_handler) if options.deprecate
              handle_async_and_promise = ->
                return if state.killed
                return handle_multiple_call Error 'Multiple call detected' if called
                called = true
                args = [].slice.call(arguments, 0)
                setImmediate ->
                  do_next args
              if options_handler_length is 2 # Async style
                promise_returned = false
                result = options_handler.call proxy, options: opts, ->
                  return if promise_returned
                  handle_async_and_promise.apply null, arguments
                if promise.is result
                  promise_returned = true
                  return handle_async_and_promise Error 'Invalid Promise: returning promise is not supported in asynchronuous mode'
              else # Sync style
                result = options_handler.call proxy, options: opts
                if promise.is result # result is a promisee
                  result.then (value) ->
                    value = [value] unless Array.isArray value
                    handle_async_and_promise null, value...
                  , (reason) ->
                    reason = Error 'Rejected Promise: reject called without any arguments' unless reason?
                    handle_async_and_promise reason
                else
                  return if state.killed
                  return handle_multiple_call Error 'Multiple call detected' if called
                  called = true
                  status_sync = false
                  wait_children = ->
                    unless state.current_level.length
                      return setImmediate ->
                        do_next [null, status_sync]
                    loptions = state.current_level.shift()
                    run loptions, (err, {status}) ->
                      return do_next [err] if err
                      # Discover status of all unshy children
                      status_sync = true if status and not loptions.shy
                      wait_children()
                  wait_children()
            catch err
              state.current_level = []
              do_next [err]
          do_intercept_after = (args, callback) ->
            return do_options_after args if options.intercepting
            each state.afters
            .call (after, next) ->
              for k, v of after then switch k
                when 'handler' then continue
                when 'action' then return next() unless array.compare v, options[k]
                else return next() unless v is options[k]
              opts = intercepting: true
              for k, v of after
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              opts.callback_arguments = args
              run opts, next
            .error (err) -> do_callback [err, status: false]
            .next -> do_options_after args
          do_options_after = (args) ->
            return do_callback args if options.options_after
            options.after ?= []
            options.after = [options.after] unless Array.isArray options.after
            each options.after
            .call (after, next) ->
              after = normalize_options [after], 'call', enrich: false
              after = after[0]
              opts = options_after: true
              for k, v of after
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              run opts, next
            .error (err) -> do_callback [err, status: false]
            .next -> do_callback args
          do_callback = (args) ->
            proxy.log type: 'handled', index: index, error: args[0], status: args[1].status
            return if state.killed
            args[0] = undefined unless args[0] # Error is undefined and not null or false
            state.current_level = state.parent_levels.shift() # Exit action state and move back to parent state
            jump_to_error args[0] if args[0] and not options.relax
            state.current_level.throw_if_error = false if args[0] and options.callback
            state.current_level.status[0].value = if options.status then args[1].status else false
            call_callback options.callback, args if options.callback
            args[0] = null if options.relax
            args[1] ?= {}
            args[1].status ?= false
            args[1] = merge {}, args[1]
            callback args[0], args[1] if callback
            run()
          do_options()
      state.properties.child = get: -> ->
        module.exports(obj.options)
      state.properties.next = get: -> ->
        state.current_level.push action: 'next', handler: arguments[0]
        setImmediate _run_ if state.current_level.length is 1 # Activate the pump
        proxy
      state.properties.promise = get: -> ->
        deferred = {}
        promise = new Promise (resolve, reject)->
          deferred.resolve = resolve
          deferred.reject = reject
        state.current_level.push action: 'promise', deferred: deferred # handler: arguments[0],
        setImmediate _run_ if state.current_level.length is 1 # Activate the pump
        promise
      state.properties.end = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'end'
        state.current_level.push opts for opts in options
        setImmediate _run_ if state.current_level.length is options.length # Activate the pump
        proxy
      state.properties.call = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'call'
        {get, values} = handle_get proxy, options
        return values if get
        state.current_level.push opts for opts in options
        setImmediate _run_ if state.current_level.length is options.length # Activate the pump
        proxy
      state.properties.each = get: -> ->
        args = [].slice.call(arguments)
        arg = args.shift()
        if not arg? or typeof arg isnt 'object'
          jump_to_error Error "Invalid Argument: first argument must be an array or an object to iterate, got #{JSON.stringify arg}"
          return proxy
        options = normalize_options args, 'call'
        for opts in options
          if Array.isArray arg
            for key in arg
              opts.key = key
              @call opts
          else
            for key, value of arg
              opts.key = key
              opts.value = value
              @call opts
        proxy
      state.properties.before = get: -> ->
        arguments[0] = action: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = normalize_options arguments, null, enrich: false
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          state.befores.push opts
        proxy
      state.properties.after = get: -> ->
        arguments[0] = action: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = normalize_options arguments, null, enrich: false
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          state.afters.push opts
        proxy
      state.properties.status = get: -> (index) ->
        if arguments.length is 0
          return state.parent_levels[0].status.some (status) -> not status.shy and status.value
        else if index is false
          value = state.parent_levels[0].status.some (status) -> not status.shy and status.value
          status.value = false for status in state.parent_levels[0].status
          return value
        else if index is true
          value = state.parent_levels[0].status.some (status) -> not status.shy and status.value
          status.value = true for status in state.parent_levels[0].status
          return value
        else
          state.parent_levels[0].status[Math.abs index]?.value
      Object.defineProperties obj, state.properties
      reg = registry.registry {}
      Object.defineProperty obj.registry, 'get', get: -> (name, handler) ->
        reg.get arguments...
      Object.defineProperty obj.registry, 'register', get: -> (name, handler) ->
        reg.register arguments...
        proxy
      Object.defineProperty obj.registry, 'registered', get: -> (name, handler) ->
        reg.registered arguments...
      Object.defineProperty obj.registry, 'unregister', get: -> (name, handler) ->
        reg.unregister arguments...
        proxy
      # Todo: remove
      if obj.options.ssh
        if obj.options.ssh.config
          obj.store['nikita:ssh:connection'] = obj.options.ssh
          delete obj.options.ssh
        else
          proxy.ssh.open obj.options.ssh if not obj.options.no_ssh
      proxy

    module.exports.cascade =
      cwd: true
      ssh: true
      log: true
      stdout: true
      stderr: true
      debug: true
      after: false
      before: false
      cascade: true
      depth: null
      disabled: false
      domain: false
      handler: false
      header: null
      once: false
      relax: false
      shy: false
      sleep: false
      sudo: true

## Helper functions

    state_create_level = ->
      todos = []
      state_reset_level todos
      todos
    state_reset_level = (todos) ->
      todos.err = null
      todos.status = []
      todos.throw_if_error = true

## Dependencies

    registry = require './registry'
    domain = require 'domain'
    each = require 'each'
    path = require 'path'
    util = require 'util'
    array = require './misc/array'
    promise = require './misc/promise'
    conditions = require './misc/conditions'
    wrap = require './misc/wrap'
    string = require './misc/string'
    {merge} = require './misc'
    {EventEmitter} = require 'events'
