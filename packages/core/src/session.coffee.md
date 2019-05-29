
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
      obj.cascade = {...module.exports.cascade, ...obj.options.cascade}
      # Internal state
      state = {}
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
        apply: (target, self, argumentsList) ->
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
              options = args_to_action args, proxy.action
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
      args_to_action = (_arguments, action_name) ->
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
          action.action = action_name if action_name
          action.action = [action.action] unless Array.isArray action.action
          action.once = ['handler'] if action.once is true
          delete action.once if action.once is false
          action.once = action.once.sort() if Array.isArray action.once
          action.once = action.once.sort() if Array.isArray action.once
          action
        actions
      handle_get = (proxy, options) ->
        return get: false unless options.length is 1
        options = options[0]
        return get: false unless options.get is true
        context = make_action obj, state.current_level.context, options
        values = context.handler.call proxy, context
        get: true, values: values
      call_callback = (context) ->
        state.parent_levels.unshift state.current_level
        state.current_level = state_create_level()
        state.current_level.context = context
        try
          context.callback.call proxy, context.error, context.output, (context.args or [])...
        catch error
          state.current_level = state.parent_levels.shift()
          context.error_in_callback = true
          context.error = error
          jump_to_error()
          return
        current_level = state.current_level
        state.current_level = state.parent_levels.shift()
        state.current_level.todos.unshift current_level.todos... if current_level.todos.length
      handle_multiple_call = (context, error) ->
        state.killed = true
        state.current_level = state.parent_levels.shift() while state.parent_levels.length
        context.error = error
        state.current_level.history.push context
        jump_to_error()
        run_next()
      jump_to_error = ->
        while state.current_level.todos[0] and state.current_level.todos[0].action not in ['catch', 'next', 'promise'] then state.current_level.todos.shift()
      run_next = ->
        options = state.current_level.todos.shift()
        # Nothing more to do in current queue
        unless options
          errors = state.current_level.history.map (context) ->
            (context.error_in_callback or not context.internal.tolerant and not context.original.relax) and context.error
          error = errors[errors.length - 1]
          if not state.killed and state.parent_levels.length is 0 and error and state.current_level.throw_if_error
            if obj.listenerCount('error') is 0
            then throw error
            else obj.emit 'error', error
          if state.parent_levels.length is 0
            obj.emit 'end', level: 'INFO' unless error
          return
        run options, ->
          run_next()
      run = (options, callback) ->
        throw Error 'Invalid Argument' unless options and callback
        if options.action is 'next'
          errors = state.current_level.history.map (context) ->
            (context.error_in_callback or not context.internal.tolerant and not context.original.relax) and context.error
          error = errors[errors.length - 1]
          status = state.current_level.history.some (context) ->
            not context.original.shy and context.status
          options.handler?.call proxy, error, {status: status}
          state_reset_level state.current_level
          return callback null, {}
        if options.action is 'promise'
          errors = state.current_level.history.map (context) ->
            (context.error_in_callback or not context.internal.tolerant and not context.original.relax) and context.error
            # context.error and (context.error.fatal or (not context.internal.tolerant and not context.original.relax))
          error = errors[errors.length - 1]
          status = state.current_level.history.some (context) ->
            not context.original.shy and context.status
          options.handler?.call proxy, error, status
          unless error
          then options.deferred.resolve status
          else options.deferred.reject error
          state_reset_level state.current_level
          return callback null, {}
        return if state.killed
        if array.compare options.action, ['end']
          return conditions.all proxy, options: options
          , ->
            while state.current_level.todos[0] and state.current_level.todos[0].action not in ['next', 'promise'] then state.current_level.todos.shift()
            callback null, {}
          , (error) ->
            callback error, {}
        index = state.index_counter++
        context_parent = state.current_level.context
        context = make_action obj, context_parent, options
        # Prepare the Context
        context.session = proxy
        state.parent_levels.unshift state.current_level
        state.current_level = state_create_level()
        state.current_level.context = context
        proxy.log message: context.internal.header, type: 'header', index: index, headers: context.internal.headers if context.internal.header
        do ->
          do_options = ->
            try
              # Validate sleep option, more can be added
              throw Error "Invalid options sleep, got #{JSON.stringify context.internal.sleep}" unless typeof context.internal.sleep is 'number' and context.internal.sleep >= 0
            catch error
              context.error = error
              context.output = status: false
              do_callback()
              return
            do_disabled()
          do_disabled = ->
            unless context.internal.disabled
              proxy.log type: 'lifecycle', message: 'disabled_false', level: 'DEBUG', index: index, error: null, status: false
              do_once()
            else
              proxy.log type: 'lifecycle', message: 'disabled_true', level: 'INFO', index: index, error: null, status: false
              context.error = undefined
              context.output = status: false
              do_callback()
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
            if context.internal.once
              if typeof context.internal.once is 'string'
                hash = string.hash context.internal.once
              else if Array.isArray context.internal.once
                hash = string.hash context.internal.once.map((k) ->
                  if k is 'handler'
                  then hashme context.handler
                  else hashme context.internal[k]
                ).join '|'
              else
                throw Error "Invalid Option 'once': #{JSON.stringify context.internal.once} must be a string or an array of string"
              if state.once[hash]
                context.error = undefined
                context.output = status: false
                return do_callback()
              state.once[hash] = true
            do_options_before()
          do_options_before = ->
            return do_intercept_before() if context.original.options_before
            context.internal.before ?= []
            context.internal.before = [context.internal.before] unless Array.isArray context.internal.before
            each context.internal.before
            .call (before, next) ->
              [before] = args_to_action [before], 'call'
              _opts = options_before: true
              for k, v of before
                _opts[k] = v
              for k, v of context.options
                _opts[k] ?= v
              run _opts, next
            .error (error) ->
              context.error = error
              context.output = status: false
              do_callback()
            .next do_intercept_before
          do_intercept_before = ->
            return do_conditions() if context.options.intercepting
            each state.befores
            .call (before, next) ->
              for k, v of before then switch k
                when 'handler' then continue
                when 'action' then return next() unless array.compare v, context.options[k]
                else return next() unless v is context.options[k]
              _opts = intercepting: true
              for k, v of before
                _opts[k] = v
              for k, v of context.options
                _opts[k] ?= v
              run _opts, next
            .error (error) ->
              context.error = error
              context.output = status: false
              do_callback()
            .next do_conditions
          do_conditions = ->
            _opts = {}
            for k, v of context.options
              _opts[k] ?= v
            conditions.all proxy, options: _opts
            , ->
              proxy.log type: 'lifecycle', message: 'conditions_passed', index: index, error: null, status: false
              for k, v of context.options # Remove conditions from options
                delete context.options[k] if /^if.*/.test(k) or /^unless.*/.test(k)
              setImmediate -> do_handler()
            , (error) ->
              proxy.log type: 'lifecycle', message: 'conditions_failed', index: index, error: error, status: false
              setImmediate ->
                context.error = error
                context.output = status: false
                do_callback()
          do_handler = ->
            context.options.attempt++
            do_next = ({error, output, args}) ->
              context.error = if error? then error else undefined # ensure null is converted to undefined
              context.output = output
              context.args = args
              if error and error not instanceof Error
                error = Error 'First argument not a valid error'
                context.error = error
                context.output ?= {}
                context.output.status ?= false
              else
                if typeof output is 'boolean' then context.output = {status: output}
                else if not output then context.output = { status: false }
                else if typeof output isnt 'object' then context.error = Error "Invalid Argument: expect an object or a boolean, got #{JSON.stringify output}"
                else context.output.status ?= false
              proxy.log message: error.message, level: 'ERROR', index: index, module: 'nikita' if error
              if error and ( context.options.retry is true or context.options.attempt < context.options.retry - 1 )
                proxy.log message: "Retry on error, attempt #{context.options.attempt+1}", level: 'WARN', index: index, module: 'nikita'
                return setTimeout do_handler, context.options.sleep
              do_intercept_after()
            context.handler ?= obj.registry.get(context.options.action)?.handler or registry.get(context.options.action)?.handler
            return handle_multiple_call context, Error "Unregistered Middleware: #{context.options.action.join('.')}" unless context.handler
            called = false
            try
              # Handle deprecation
              context.handler = ( (options_handler) ->
                util.deprecate ->
                  options_handler.apply @, arguments
                , if context.internal.deprecate is true
                then "#{context.internal.action.join '/'} is deprecated"
                else "#{context.internal.action.join '/'} is deprecated, use #{context.internal.deprecate}"
              )(context.handler) if context.options.deprecate
              handle_async_and_promise = ->
                [error, output, args...] = arguments
                return if state.killed
                return handle_multiple_call context, Error 'Multiple call detected' if called
                called = true
                setImmediate ->
                  do_next error: error, output: output, args: args
              # Prepare the context
              ctx = {...context, options: {...context.options}}
              # Async style
              if context.handler.length is 2
                promise_returned = false
                result = context.handler.call proxy, ctx, ->
                  return if promise_returned
                  handle_async_and_promise.apply null, arguments
                if promise.is result
                  promise_returned = true
                  return handle_async_and_promise Error 'Invalid Promise: returning promise is not supported in asynchronuous mode'
              # Sync style
              else
                result = context.handler.call proxy, ctx
                if promise.is result
                  result.then (value) ->
                    if Array.isArray value
                      [output, args...] = value
                    else
                      output = value
                      args = []
                    handle_async_and_promise undefined, output, args...
                  , (reason) ->
                    reason = Error 'Rejected Promise: reject called without any arguments' unless reason?
                    handle_async_and_promise reason
                else
                  return if state.killed
                  return handle_multiple_call context, Error 'Multiple call detected' if called
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
          do_intercept_after = ->
            return do_options_after() if context.options.intercepting
            each state.afters
            .call (after, next) ->
              for k, v of after then switch k
                when 'handler' then continue
                when 'action' then return next() unless array.compare v, context.options[k]
                else return next() unless v is context.options[k]
              _opts = intercepting: true
              for k, v of after
                _opts[k] = v
              for k, v of context.options
                _opts[k] ?= v
              run _opts, next
            .error (error) ->
              context.error = error
              context.output = status: false
              do_callback()
            .next -> do_options_after()
          do_options_after = ->
            return do_callback() if context.original.options_after
            context.internal.after ?= []
            context.internal.after = [context.internal.after] unless Array.isArray context.internal.after
            each context.internal.after
            .call (after, next) ->
              [after] = args_to_action [after], 'call'
              _opts = options_after: true
              for k, v of after
                _opts[k] = v
              for k, v of context.options
                _opts[k] ?= v
              run _opts, next
            .error (error) ->
              context.error = error
              context.output = status: false
              do_callback()
            .next -> do_callback()
          do_callback = ->
            proxy.log type: 'handled', index: index, error: context.error, status: context.output.status
            return if state.killed
            state.current_level = state.parent_levels.shift() # Exit action state and move back to parent state
            state.current_level.throw_if_error = false if context.error and context.callback
            context.status = if context.internal.status then context.output.status else false
            if context.error and not context.internal.relax
              jump_to_error()
            call_callback context if context.callback
            do_end context
          do_end = (context) ->
            state.current_level.history.push context
            error = (context.error_in_callback or not context.internal.tolerant and not context.original.relax) and context.error
            callback error, context.output
          do_options()
      obj.next = ->
        state.current_level.todos.push action: 'next', handler: arguments[0]
        setImmediate run_next if state.current_level.todos.length is 1 # Activate the pump
        proxy
      obj.promise = ->
        deferred = {}
        promise = new Promise (resolve, reject)->
          deferred.resolve = resolve
          deferred.reject = reject
        state.current_level.todos.push action: 'promise', deferred: deferred
        setImmediate run_next if state.current_level.todos.length is 1 # Activate the pump
        promise
      obj.end = ->
        args = [].slice.call(arguments)
        options = args_to_action args, 'end'
        state.current_level.todos.push opts for opts in options
        setImmediate run_next if state.current_level.todos.length is options.length # Activate the pump
        proxy
      obj.call = ->
        args = [].slice.call(arguments)
        options = args_to_action args, 'call'
        {get, values} = handle_get proxy, options
        return values if get
        state.current_level.todos.push opts for opts in options
        setImmediate run_next if state.current_level.todos.length is options.length # Activate the pump
        proxy
      obj.each = ->
        args = [].slice.call(arguments)
        arg = args.shift()
        if not arg? or typeof arg isnt 'object'
          throw Error "Invalid Argument: first argument must be an array or an object to iterate, got #{JSON.stringify arg}"
        options = args_to_action args, 'call'
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
      obj.before = ->
        arguments[0] = action: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = args_to_action arguments, null
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          state.befores.push opts
        proxy
      obj.after = ->
        arguments[0] = action: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = args_to_action arguments, null
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          state.afters.push opts
        proxy
      obj.status = (index) ->
        if arguments.length is 0
          return state.parent_levels[0].history.some (action) -> not action.original.shy and action.status
        else if index is false
          status = state.parent_levels[0].history.some (action) -> not action.original.shy and action.status
          action.status = false for action in state.parent_levels[0].history
          return status
        else if index is true
          status = state.parent_levels[0].history.some (action) -> not action.original.shy and action.status
          action.status = true for action in state.parent_levels[0].history
          return status
        else if index is 0
          state.current_level.context.output?.status
        else
          l = state.parent_levels[0].history.length
          index = (l + index) if index < 0
          state.parent_levels[0].history[index]?.status
      reg = registry.registry {}
      obj.registry.get = ->
        reg.get arguments...
      obj.registry.register = ->
        reg.register arguments...
        proxy
      obj.registry.registered = ->
        reg.registered arguments...
      obj.registry.unregister = ->
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
      after: false
      before: false
      callback: false
      cascade: true
      cwd: true
      debug: true
      depth: null
      disabled: null
      handler: false
      header: null
      log: true
      once: false
      relax: false
      shy: false
      sleep: false
      ssh: true
      stdout: true
      stderr: true
      sudo: true
      tolerant: false

## Helper functions

    state_create_level = ->
      error: undefined
      history: []
      todos: []
      throw_if_error: true
    # Called after next and promise
    state_reset_level = (level) ->
      level.error = undefined
      level.history = []
      level.throw_if_error = true

## Dependencies

    # args_to_action = require './engine/args_to_action'
    make_action = require './engine/make_action'
    registry = require './registry'
    each = require 'each'
    path = require 'path'
    util = require 'util'
    array = require './misc/array'
    promise = require './misc/promise'
    conditions = require './misc/conditions'
    string = require './misc/string'
    {EventEmitter} = require 'events'
