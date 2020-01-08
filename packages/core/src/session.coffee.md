
# Nikita Session

    module.exports = ->
      if arguments.length is 1
        obj = new EventEmitter
        obj.options = arguments[0]
      else
        obj = new EventEmitter
        obj.options = {}
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
          return target[name] if name in ['_events', '_maxListeners']
          proxy.action = []
          proxy.action.push name
          if not obj.registry.registered(proxy.action, partial: true) and not registry.registered(proxy.action, partial: true)
            proxy.action = []
            return undefined
          get_proxy_builder = ->
            builder = ->
              args = [].slice.call(arguments)
              options = args_to_actions obj, args, proxy.action
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
                if not obj.registry.registered(proxy.action, partial: true) and not registry.registered(proxy.action, partial: true)
                  proxy.action = []
                  return undefined
                get_proxy_builder()
          get_proxy_builder()
      handle_get = (proxy, options) ->
        return get: false unless options.length is 1
        options = options[0]
        return get: false unless options.get is true
        action = make_action obj, state.current_level.action, options
        values = action.handler.call proxy, action
        get: true, values: values
      call_callback = (action) ->
        state.parent_levels.unshift state.current_level
        state.current_level = state_create_level()
        state.current_level.action = action
        try
          action.callback.call proxy, action.error, action.output, (action.args or [])...
        catch error
          state.current_level = state.parent_levels.shift()
          action.error_in_callback = true
          action.error = error
          jump_to_error()
          return
        current_level = state.current_level
        state.current_level = state.parent_levels.shift()
        state.current_level.todos.unshift current_level.todos... if current_level.todos.length
      handle_multiple_call = (action, error) ->
        state.killed = true
        state.current_level = state.parent_levels.shift() while state.parent_levels.length
        action.error = error
        state.current_level.history.push action
        jump_to_error()
        run_next()
      jump_to_error = ->
        while state.current_level.todos[0] and state.current_level.todos[0].action not in ['catch', 'next', 'promise'] then state.current_level.todos.shift()
      run_next = ->
        options = state.current_level.todos.shift()
        # Nothing more to do in current queue
        unless options
          errors = state.current_level.history.map (action) ->
            (action.error_in_callback or not action.metadata.tolerant and not action.original.relax) and action.error
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
          errors = state.current_level.history.map (action) ->
            (action.error_in_callback or not action.metadata.tolerant and not action.original.relax) and action.error
          error = errors[errors.length - 1]
          status = state.current_level.history.some (action) ->
            not action.original.shy and action.status
          options.handler?.call proxy, error, {status: status}
          state_reset_level state.current_level
          return callback null, {}
        if options.action is 'promise'
          errors = state.current_level.history.map (action) ->
            (action.error_in_callback or not action.metadata.tolerant and not action.original.relax) and action.error
            # action.error and (action.error.fatal or (not action.metadata.tolerant and not action.original.relax))
          error = errors[errors.length - 1]
          status = state.current_level.history.some (action) ->
            not action.original.shy and action.status
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
        action_parent = state.current_level.action
        action = make_action obj, action_parent, options
        # Prepare the Context
        action.session = proxy
        state.parent_levels.unshift state.current_level
        state.current_level = state_create_level()
        state.current_level.action = action
        proxy.log message: action.metadata.header, type: 'header', index: index if action.metadata.header
        do ->
          do_options = ->
            action.on_options action if action.on_options
            try
              if action.metadata.schema
                errors = obj.schema.validate action.options, action.metadata.schema
                if errors.length
                  if errors.length is 1
                    throw errors[0]
                  else
                    error = new Error 'Invalid Options'
                    error.errors = errors
                    throw error
              # Validate sleep option, more can be added
              throw Error "Invalid options sleep, got #{JSON.stringify action.metadata.sleep}" unless typeof action.metadata.sleep is 'number' and action.metadata.sleep >= 0
            catch error
              action.error = error
              action.output = status: false
              do_callback()
              return
            do_disabled()
          do_disabled = ->
            unless action.metadata.disabled
              proxy.log type: 'lifecycle', message: 'disabled_false', level: 'DEBUG', index: index, error: null, status: false
              do_once()
            else
              proxy.log type: 'lifecycle', message: 'disabled_true', level: 'INFO', index: index, error: null, status: false
              action.error = undefined
              action.output = status: false
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
            if action.metadata.once
              if typeof action.metadata.once is 'string'
                hash = string.hash action.metadata.once
              else if Array.isArray action.metadata.once
                hash = string.hash action.metadata.once.map((k) ->
                  # TODO, we need a more reliable way to detect metadata,
                  # options and other action properties
                  if k is 'handler'
                  then hashme action.handler
                  else if make_action.metadata[k] isnt undefined
                  then hashme action.metadata[k]
                  else hashme action.options[k]
                ).join '|'
              else
                throw Error "Invalid Option 'once': #{JSON.stringify action.metadata.once} must be a string or an array of string"
              if state.once[hash]
                action.error = undefined
                action.output = status: false
                return do_callback()
              state.once[hash] = true
            do_options_before()
          do_options_before = ->
            return do_intercept_before() if action.original.options_before
            action.metadata.before ?= []
            action.metadata.before = [action.metadata.before] unless Array.isArray action.metadata.before
            each action.metadata.before
            .call (before, next) ->
              [before] = args_to_actions obj, [before], 'call'
              _opts = options_before: true
              for k, v of before
                _opts[k] = v
              for k, v of action.options
                _opts[k] ?= v
              run _opts, next
            .error (error) ->
              action.error = error
              action.output = status: false
              do_callback()
            .next do_intercept_before
          do_intercept_before = ->
            return do_conditions() if action.options.intercepting
            each state.befores
            .call (before, next) ->
              for k, v of before then switch k
                when 'handler' then continue
                when 'action' then return next() unless array.compare v, action.options[k]
                else return next() unless v is action.options[k]
              _opts = intercepting: true
              for k, v of before
                _opts[k] = v
              for k, v of action.options
                _opts[k] ?= v
              run _opts, next
            .error (error) ->
              action.error = error
              action.output = status: false
              do_callback()
            .next do_conditions
          do_conditions = ->
            _opts = {}
            for k, v of action.options
              _opts[k] ?= v
            conditions.all proxy, options: _opts, metadata: action.metadata
            , ->
              proxy.log type: 'lifecycle', message: 'conditions_passed', index: index, error: null, status: false
              for k, v of action.options # Remove conditions from options
                delete action.options[k] if /^if.*/.test(k) or /^unless.*/.test(k)
              setImmediate -> do_handler()
            , (error) ->
              proxy.log type: 'lifecycle', message: 'conditions_failed', index: index, error: error, status: false
              setImmediate ->
                action.error = error
                action.output = status: false
                do_callback()
          do_handler = ->
            action.metadata.attempt++
            do_next = ({error, output, args}) ->
              action.error = if error? then error else undefined # ensure null is converted to undefined
              action.output = output
              action.args = args
              if error and error not instanceof Error
                error = Error 'First argument not a valid error'
                action.error = error
                action.output ?= {}
                action.output.status ?= false
              else
                if typeof output is 'boolean' then action.output = {status: output}
                else if not output then action.output = { status: false }
                else if typeof output isnt 'object' then action.error = Error "Invalid Argument: expect an object or a boolean, got #{JSON.stringify output}"
                else action.output.status ?= false
              proxy.log message: error.message, level: 'ERROR', index: index, module: 'nikita' if error
              if error and ( action.metadata.retry is true or action.metadata.attempt < action.metadata.retry - 1 )
                proxy.log message: "Retry on error, attempt #{action.metadata.attempt+1}", level: 'WARN', index: index, module: 'nikita'
                return setTimeout do_handler, action.metadata.sleep
              do_intercept_after()
            action.handler ?= obj.registry.get(action.action)?.handler or registry.get(action.action)?.handler
            return handle_multiple_call action, Error "Unregistered Middleware: #{action.action.join('.')}" unless action.handler
            called = false
            try
              # Handle deprecation
              action.handler = ( (options_handler) ->
                util.deprecate ->
                  options_handler.apply @, arguments
                , if action.metadata.deprecate is true
                then "#{action.action.join '/'} is deprecated"
                else "#{action.action.join '/'} is deprecated, use #{action.metadata.deprecate}"
              )(action.handler) if action.metadata.deprecate
              handle_async_and_promise = ->
                [error, output, args...] = arguments
                return if state.killed
                return handle_multiple_call action, Error 'Multiple call detected' if called
                called = true
                setImmediate ->
                  do_next error: error, output: output, args: args
              # Prepare the context
              ctx = {...action, options: {...action.options}}
              # Async style
              if action.handler.length is 2
                promise_returned = false
                result = action.handler.call proxy, ctx, ->
                  return if promise_returned
                  handle_async_and_promise.apply null, arguments
                if promise.is result
                  promise_returned = true
                  return handle_async_and_promise Error 'Invalid Promise: returning promise is not supported in asynchronuous mode'
              # Sync style
              else
                result = action.handler.call proxy, ctx
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
                  return handle_multiple_call action, Error 'Multiple call detected' if called
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
            return do_options_after() if action.options.intercepting
            each state.afters
            .call (after, next) ->
              for k, v of after then switch k
                when 'handler' then continue
                when 'action' then return next() unless array.compare v, action.options[k]
                else return next() unless v is action.options[k]
              _opts = intercepting: true
              for k, v of after
                _opts[k] = v
              for k, v of action.options
                _opts[k] ?= v
              run _opts, next
            .error (error) ->
              action.error = error
              action.output = status: false
              do_callback()
            .next -> do_options_after()
          do_options_after = ->
            return do_callback() if action.original.options_after
            action.metadata.after ?= []
            action.metadata.after = [action.metadata.after] unless Array.isArray action.metadata.after
            each action.metadata.after
            .call (after, next) ->
              [after] = args_to_actions obj, [after], 'call'
              _opts = options_after: true
              for k, v of after
                _opts[k] = v
              for k, v of action.options
                _opts[k] ?= v
              run _opts, next
            .error (error) ->
              action.error = error
              action.output = status: false
              do_callback()
            .next -> do_callback()
          do_callback = ->
            proxy.log type: 'handled', index: index, error: action.error, status: action.output.status
            return if state.killed
            state.current_level = state.parent_levels.shift() # Exit action state and move back to parent state
            state.current_level.throw_if_error = false if action.error and action.callback
            action.status = if action.metadata.status then action.output.status else false
            if action.error and not action.metadata.relax
              jump_to_error()
            call_callback action if action.callback
            do_end action
          do_end = (action) ->
            state.current_level.history.push action
            error = (action.error_in_callback or not action.metadata.tolerant and not action.original.relax) and action.error
            callback error, action.output
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
        options = args_to_actions obj, args, 'end'
        state.current_level.todos.push opts for opts in options
        setImmediate run_next if state.current_level.todos.length is options.length # Activate the pump
        proxy
      obj.call = ->
        args = [].slice.call(arguments)
        options = args_to_actions obj, args, 'call'
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
        options = args_to_actions obj, args, 'call'
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
        options = args_to_actions obj, arguments, null
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          state.befores.push opts
        proxy
      obj.after = ->
        arguments[0] = action: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = args_to_actions obj, arguments, null
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          state.afters.push opts
        proxy
      obj.status = (index) ->
        if arguments.length is 0
          return state.parent_levels[0].history.some (action) ->
            not action.original.shy and action.status
        else if index is false
          status = state.parent_levels[0].history.some (action) -> not action.original.shy and action.status
          action.status = false for action in state.parent_levels[0].history
          return status
        else if index is true
          status = state.parent_levels[0].history.some (action) -> not action.original.shy and action.status
          action.status = true for action in state.parent_levels[0].history
          return status
        else if index is 0
          state.current_level.action.output?.status
        else
          l = state.parent_levels[0].history.length
          index = (l + index) if index < 0
          state.parent_levels[0].history[index]?.status
      obj.registry = registry.registry
        parent: registry
        chain: proxy
        on_register: (name, action) ->
          return unless action.schema
          name = "/nikita/#{name.join('/')}"
          obj.schema.add name, action.schema
      obj.schema = schema()
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

    args_to_actions = require './engine/args_to_actions'
    make_action = require './engine/make_action'
    schema = require './engine/schema'
    registry = require './registry'
    each = require 'each'
    path = require 'path'
    util = require 'util'
    array = require './misc/array'
    promise = require './misc/promise'
    conditions = require './misc/conditions'
    string = require './misc/string'
    {EventEmitter} = require 'events'
