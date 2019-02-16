
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
      # Proxify
      proxy = new Proxy obj,
        has: (target, name) ->
          console.warns 'proxy has is being called', name
        apply: (target, thisArg, argumentsList) ->
          console.warn 'apply'
        get: (target, name) ->
          return target[name] if obj[name]?
          return target[name] if name in ['_events', '_maxListeners', 'internal']
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
              state.current_level.todos.push opts for opts in options
              setImmediate run_next if state.current_level.todos.length is options.length # Activate the pump
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
          # Validation
          if params.handler
            throw Error 'Missing handler option' unless action.handler
            throw Error "Invalid Handler: expect a function, got '#{action.handler}'" unless typeof action.handler is 'function'
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
      call_callback = (fn, callbackargs) ->
        options = state.current_level.options
        state.parent_levels.unshift state.current_level
        state.current_level = state_create_level()
        state.current_level.options = options
        try
          fn.call proxy, callbackargs.error, callbackargs.output, (callbackargs.args or [])...
        catch error
          state.current_level = state.parent_levels.shift()
          state.current_level.error = error
          jump_to_error()
          callbackargs.error = error
          return run_next()
        current_level = state.current_level
        state.current_level = state.parent_levels.shift()
        state.current_level.todos.unshift current_level.todos... if current_level.todos.length
      handle_multiple_call = (error) ->
        state.killed = true
        state.current_level = state.parent_levels.shift() while state.parent_levels.length
        state.current_level.error = error
        jump_to_error()
        run_next()
      jump_to_error = ->
        while state.current_level.todos[0] and state.current_level.todos[0].action not in ['catch', 'next', 'promise'] then state.current_level.todos.shift()
      run_next = (callback) ->
        options = state.current_level.todos.shift()
        # Nothing more to do in current queue
        unless options
          if not state.killed and state.parent_levels.length is 0 and state.current_level.error and state.current_level.throw_if_error
            obj.emit 'error', state.current_level.error
            throw state.current_level.error unless obj.listenerCount() is 0
          if state.parent_levels.length is 0
            obj.emit 'end', level: 'INFO' unless state.current_level.error
          return
        run options
      run = (options, callback) ->
        # options = state.current_level.todos.shift() unless options
        options_original = options
        options_parent = state.current_level.options
        obj.cascade = {...obj.options.cascade, ...module.exports.cascade}
        for k, v of options_parent
          options_original[k] = v if options_original[k] is undefined and obj.cascade[k] is true
        options.original = options_original
        if options.action is 'next'
          {error, history} = state.current_level
          unless error
            errors = history.some (action) -> not action.options.tolerant and error
            error = errors[errors.length - 1]
          status = history.some (action) -> not action.options.shy and action.status
          options.handler?.call proxy, error, {status: status}
          state_reset_level state.current_level
          run_next()
          return
        if options.action is 'promise'
          {error, history} = state.current_level
          unless error
            errors = history.some (action) -> not action.options.tolerant and error
            error = errors[errors.length - 1]
          status = history.some (action) -> not action.options.shy and action.status
          options.handler?.call proxy, error, status
          unless error
          then options.deferred.resolve status
          else options.deferred.reject error
          state_reset_level state.current_level
          return
        return if state.killed
        if array.compare options.action, ['end']
          return conditions.all proxy, options: options
          , ->
            while state.current_level.todos[0] and state.current_level.todos[0].action not in ['next', 'promise'] then state.current_level.todos.shift()
            callback error, {} if callback
            run_next()
          , (error) ->
            callback error, {} if callback
            run_next()
        options = enrich_options options
        index = state.index_counter++
        state.current_level.history.unshift status: undefined, options: shy: options.shy
        state.parent_levels.unshift state.current_level
        state.current_level = state_create_level()
        state.current_level.options = options
        proxy.log message: options.header, type: 'header', index: index, headers: options.headers if options.header
        do () ->
          do_options = ->
            try
              # Validation
              throw Error "Invalid options sleep, got #{JSON.stringify options.sleep}" unless typeof options.sleep is 'number' and options.sleep >= 0
            catch error
              do_callback error: error, output: status: false
              return
            wrap.options options, (error) ->
              do_disabled()
          do_disabled = ->
            unless options.disabled
              proxy.log type: 'lifecycle', message: 'disabled_false', level: 'DEBUG', index: index, error: null, status: false
              do_once()
            else
              proxy.log type: 'lifecycle', message: 'disabled_true', level: 'INFO', index: index, error: null, status: false
              do_callback error: undefined, output: status: false
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
              return do_callback error: undefined, output: status: false if state.once[hash]
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
            .error (error) -> do_callback error: error, output: status: false
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
            .error (error) -> do_callback error: error, output: status: false
            .next do_conditions
          do_conditions = ->
            opts = {}
            for k, v of options
              continue if k in ['handler', 'callback', 'header', 'after', 'before']
              opts[k] ?= v
            conditions.all proxy, options: opts
            , ->
              proxy.log type: 'lifecycle', message: 'conditions_passed', index: index, error: null, status: false
              for k, v of options # Remove conditions from options
                delete options[k] if /^if.*/.test(k) or /^unless.*/.test(k)
              setImmediate -> do_handler()
            , (error) ->
              proxy.log type: 'lifecycle', message: 'conditions_failed', index: index, error: error, status: false
              setImmediate -> do_callback error: error, output: status: false
          options.attempt = -1
          do_handler = ->
            options.attempt++
            do_next = ({error, output, args}) ->
              callbackargs = error: error, output: output, args: args
              options.handler = options_handler
              options.callback = options_callback
              if error and error not instanceof Error
                error = Error 'First argument not a valid error'
                callbackargs.error = error
                callbackargs.output ?= {}
                callbackargs.output.status ?= false
              else
                if typeof output is 'boolean' then callbackargs.output = {status: output}
                else if not output then callbackargs.output = { status: false }
                else if typeof output isnt 'object' then callbackargs.error = Error "Invalid Argument: expect an object or a boolean, got #{JSON.stringify output}"
                else callbackargs.output.status ?= false
              proxy.log message: error.message, level: 'ERROR', index: index, module: 'nikita' if error
              if error and ( options.retry is true or options.attempt < options.retry - 1 )
                proxy.log message: "Retry on error, attempt #{options.attempt+1}", level: 'WARN', index: index, module: 'nikita'
                return setTimeout do_handler, options.sleep
              do_intercept_after callbackargs
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
                [error, output, args...] = arguments
                return if state.killed
                return handle_multiple_call Error 'Multiple call detected' if called
                called = true
                setImmediate ->
                  do_next error: error, output: output, args: args
              # Prepare the Context
              context =
                options: opts
                session: proxy
              # Call the action
              if options_handler_length is 2 # Async style
                promise_returned = false
                result = options_handler.call proxy, context, ->
                  return if promise_returned
                  handle_async_and_promise.apply null, arguments
                if promise.is result
                  promise_returned = true
                  return handle_async_and_promise Error 'Invalid Promise: returning promise is not supported in asynchronuous mode'
              else # Sync style
                result = options_handler.call proxy, context
                if promise.is result # result is a promise
                  result.then (value) ->
                    if Array.isArray value
                      [output, args...] = value
                    else
                      output = value
                      args = []
                    # value = [value] unless Array.isArray value
                    # handle_async_and_promise error: null, output: output, args: args
                    handle_async_and_promise undefined, output, args...
                  , (reason) ->
                    reason = Error 'Rejected Promise: reject called without any arguments' unless reason?
                    # handle_async_and_promise error: reason
                    handle_async_and_promise reason
                else
                  return if state.killed
                  return handle_multiple_call Error 'Multiple call detected' if called
                  called = true
                  status_sync = false
                  wait_children = ->
                    unless state.current_level.todos.length
                      return setImmediate ->
                        do_next output: status: status_sync
                    loptions = state.current_level.todos.shift()
                    run loptions, (error, {status}) ->
                      return do_next error: error if error
                      # Discover status of all unshy children
                      status_sync = true if status and not loptions.shy
                      wait_children()
                  wait_children()
            catch error
              state.current_level = state_create_level()
              do_next error: error
          do_intercept_after = (callbackargs) ->
            return do_options_after callbackargs if options.intercepting
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
              opts.callback_arguments = callbackargs
              run opts, next
            .error (error) -> do_callback error: error, output: status: false
            .next -> do_options_after callbackargs
          do_options_after = (callbackargs) ->
            return do_callback callbackargs if options.options_after
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
            .error (error) -> do_callback error: error, output: status: false
            .next -> do_callback callbackargs
          do_callback = (callbackargs) ->
            proxy.log type: 'handled', index: index, error: callbackargs.error, status: callbackargs.output.status
            return if state.killed
            callbackargs.error = undefined unless callbackargs.error # Error is undefined and not null or false
            state.current_level = state.parent_levels.shift() # Exit action state and move back to parent state
            state.current_level.throw_if_error = false if callbackargs.error and options.callback
            state.current_level.history[0].status = if options.status then callbackargs.output.status else false
            state.current_level.history[0].error = callbackargs.error
            state.current_level.history[0].output = callbackargs.output
            if callbackargs.error and not options.relax
              state.current_level.error = callbackargs.error
              jump_to_error()
            call_callback options.callback, callbackargs if options.callback
            callbackargs.error = null if options.relax
            callbackargs.output ?= {}
            callbackargs.output.status ?= false
            callbackargs.output = mixme {}, callbackargs.output
            do_end callbackargs
          do_end = (callbackargs) ->
            callback callbackargs.error, callbackargs.output if callback
            run_next()
          do_options()
      state.properties.child = get: -> ->
        module.exports(obj.options)
      state.properties.next = get: -> ->
        state.current_level.todos.push action: 'next', handler: arguments[0]
        setImmediate run_next if state.current_level.todos.length is 1 # Activate the pump
        proxy
      state.properties.promise = get: -> ->
        deferred = {}
        promise = new Promise (resolve, reject)->
          deferred.resolve = resolve
          deferred.reject = reject
        state.current_level.todos.push action: 'promise', deferred: deferred # handler: arguments[0],
        setImmediate run_next if state.current_level.todos.length is 1 # Activate the pump
        promise
      state.properties.end = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'end'
        state.current_level.todos.push opts for opts in options
        setImmediate run_next if state.current_level.todos.length is options.length # Activate the pump
        proxy
      state.properties.call = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'call'
        {get, values} = handle_get proxy, options
        return values if get
        state.current_level.todos.push opts for opts in options
        setImmediate run_next if state.current_level.todos.length is options.length # Activate the pump
        proxy
      state.properties.each = get: -> ->
        args = [].slice.call(arguments)
        arg = args.shift()
        if not arg? or typeof arg isnt 'object'
          state.current_level.error = Error "Invalid Argument: first argument must be an array or an object to iterate, got #{JSON.stringify arg}"
          jump_to_error() 
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
          return state.parent_levels[0].history.some (action) -> not action.options.shy and action.status
        else if index is false
          status = state.parent_levels[0].history.some (action) -> not action.options.shy and action.status
          action.status = false for action in state.parent_levels[0].history
          return status
        else if index is true
          status = state.parent_levels[0].history.some (action) -> not action.options.shy and action.status
          action.status = true for action in state.parent_levels[0].history
          return status
        else
          state.parent_levels[0].history[Math.abs index]?.status
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
      handler: false
      header: null
      once: false
      relax: false
      shy: false
      sleep: false
      sudo: true

## Helper functions

    state_create_level = ->
      level =
        error: null
        history: []
        current:
          options: {}
          status: undefined
          output: null
          args: null
        todos: []
        throw_if_error: true
    # Called after next and promise
    state_reset_level = (level) ->
      level.error = null
      level.history = []
      level.throw_if_error = true

## Dependencies

    registry = require './registry'
    each = require 'each'
    mixme = require 'mixme'
    path = require 'path'
    util = require 'util'
    array = require './misc/array'
    promise = require './misc/promise'
    conditions = require './misc/conditions'
    wrap = require './misc/wrap'
    string = require './misc/string'
    {EventEmitter} = require 'events'
