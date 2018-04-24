
# Nikita Context

    called_deprecate_destination = false
    called_deprecate_local_source = false
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
      obj.propagation ?= obj.options.propagation or {}
      obj.store ?= {}
      # Merge global default propagation
      for k, v of module.exports.propagation
        obj.propagation[k] = v unless obj.propagation[k] isnt undefined
      # Internal state
      state = {}
      state.properties = {}
      state.stack = []
      state.todos = todos_create()
      state.befores = []
      state.afters = []
      state.depth = 0
      state.headers = []
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
          # target[name]? or target.registry.registered(proxy.type)? or registry.registered(name)?
        apply: (target, thisArg, argumentsList) ->
          console.warn 'apply'
        get: (target, name) ->
          return target[name] if obj[name]?
          return target[name] if name in ['domain', '_events', '_maxListeners']
          proxy.type = []
          proxy.type.push name
          if not obj.registry.registered(proxy.type, parent: true) and not registry.registered(proxy.type, parent: true)
            proxy.type = []
            return undefined
          get_proxy_builder = ->
            builder = ->
              args = [].slice.call(arguments)
              options = normalize_options args, proxy.type
              {get, values} = handle_get proxy, options
              return values if get
              proxy.type = []
              state.todos.push opts for opts in options
              setImmediate _run_ if state.todos.length is options.length # Activate the pump
              proxy
            new Proxy builder,
              get: (target, name) ->
                return target[name] if target[name]?
                proxy.type.push name
                if not obj.registry.registered(proxy.type, parent: true) and not registry.registered(proxy.type, parent: true)
                  proxy.type = []
                  return undefined
                get_proxy_builder()
          get_proxy_builder()
      normalize_options = (_arguments, type, enrich=true) ->
        empty = false
        middleware = obj.registry.get(type) or registry.get(type) if Array.isArray(type)
        _arguments.unshift middleware.handler if middleware
        handler = null
        callback = null
        options = []
        for arg in _arguments
          if typeof arg is 'function'
            if not handler then handler = arg
            else unless callback then callback = arg
            else throw Error "Invalid third function argument"
          else if Array.isArray arg
            empty = true if arg.length is 0
            for a in arg
              if type is 'call'
                a = handler: a unless typeof a is 'object' and not Array.isArray(a) and a isnt null
              else
                a = argument: a unless typeof a is 'object' and not Array.isArray(a) and a isnt null
              options.push a
          else
            if typeof arg isnt 'object' and arg isnt null
              arg = argument: arg
            if options.length is 0
              cloned_arg = {}
              for k, v of arg then cloned_arg[k] = v
              options.push cloned_arg
            else for opts in options
              for k, v of arg then opts[k] = v
        return options if options.length is 0 and empty
        options.push {} if options.length is 0
        if options.length and options.filter( (opts) -> not opts.handler ).length is 0
          callback = handler
          handler = null
        # Normalize
        for opts, i in options
          # Clone
          options[i] = {}
          merge options[i], middleware if Array.isArray(type)
          options[i][k] = v for k, v of opts
          opts = options[i]
          # Argument
          if type is 'call' and not opts.handler #and typeof opts.argument is 'function'
            opts.handler = opts.argument
            opts.argument = undefined
          # Enrich
          if opts.destination
            console.info 'Use options target instead of destination' unless called_deprecate_destination
            called_deprecate_destination = true
            opts.target ?= opts.destination
          if opts.local_source
            console.info 'Use options local instead of local_source' unless called_deprecate_local_source
            called_deprecate_local_source = true
            opts.local ?= opts.local_source
          opts.type = type if type
          opts.type = [opts.type] unless Array.isArray opts.type
          opts.handler ?= handler if handler
          opts.callback ?= callback if callback
          opts.user_args = true if enrich and opts.callback?.length > 2
          opts.once = ['handler'] if opts.once is true
          delete opts.once if opts.once is false
          opts.once = opts.once.sort() if Array.isArray opts.once
          opts.sleep ?= 3000 # Wait 3s between retry
          opts.retry ?= 0
          opts.disabled ?= false
          opts.status ?= true
          throw Error 'Incompatible Options: status "false" implies shy "true"' if opts.status is false and opts.shy is false # Room for argument, leave it strict for now until we come accross a usecase justifying it.
          opts.shy ?= true if opts.status is false
          # Validation
          jump_to_error Error "Invalid options sleep, got #{JSON.stringify opts.sleep}" unless typeof opts.sleep is 'number' and opts.sleep >= 0
        options
      enrich_options = (user_options) ->
        user_options.enriched = true
        global_options = obj.options
        parent_options = state.todos.options
        options = {}
        for k, v of user_options then options[k] = user_options[k]
        for k, v of parent_options
          options[k] = v if options[k] is undefined and obj.propagation[k]
        for k, v of global_options
          options[k] = v if options[k] is undefined
        unless options.log?.dont
          if options.log and not Array.isArray options.log
            _logs = [options.log]
          else if not options.log
            _logs = []
        log_disabled = true if options.log is false
        options.log = [] if log_disabled
        options.log = [] if options.log?._nikita_ # not clean but no better way to detect user provided option with the one from nikita
        options.log ?= []
        options.log = [options.log] unless Array.isArray options.log
        _logs = options.log
        if options.debug
          _logs.push (log) ->
            return unless log.type in ['text', 'stdin', 'stdout_stream', 'stderr_stream']
            return if log.type in ['stdout_stream', 'stderr_stream'] and log.message is null
            msg = if log.message?.toString? then log.message.toString() else log.message
            msg = "[#{log.total_depth}.#{log.level} #{log.module}] #{JSON.stringify msg}"
            msg = switch log.type
              when 'stdin' then "\x1b[33m#{msg}\x1b[39m"
              when 'stdout_stream' then "\x1b[36m#{msg}\x1b[39m"
              when 'stderr_stream' then "\x1b[35m#{msg}\x1b[39m"
              else "\x1b[32m#{msg}\x1b[39m"
            process.stdout.write "#{msg}\n" # todo: switch with stderr
        options.log = (log) ->
          log = message: log if typeof log is 'string'
          log.level ?= 'INFO'
          log.time ?= Date.now()
          log.module ?= undefined
          log.header_depth ?= state.depth
          log.headers ?= header for header in state.headers
          log.total_depth ?= state.stack.length
          log.type ?= 'text'
          log.shy ?= options.shy
          args = if 1 <= arguments.length then [].slice.call(arguments, 0) else []
          stackTrace = require 'stack-trace'
          frame = stackTrace.get()[1]
          file = path.basename(frame.getFileName())
          line = frame.getLineNumber()
          method = frame.getFunctionName()
          log.file = file
          log.line = line
          args.unshift("" + file + ":" + line + " in " + method + "()");
          _log log for _log in _logs
          obj.emit? log.type, log unless log_disabled
        options.log._nikita_ = true
        if options.source and match = /~($|\/.*)/.exec options.source
          unless obj.store['nikita:ssh:connection']
          then options.source = path.join process.env.HOME, match[1]
          else options.source = path.posix.join '.', match[1]
        if options.target and match = /~($|\/.*)/.exec options.target
          unless obj.store['nikita:ssh:connection']
          then options.target = path.join process.env.HOME, match[1]
          else options.target = path.posix.join '.', match[1]
        options
      call_callback = (fn, args) ->
        state.stack.unshift state.todos
        state.todos = todos_create()
        try
          fn.apply proxy, args
        catch err
          state.todos = state.stack.shift()
          jump_to_error err
          args[0] = err
          return run()
        mtodos = state.todos
        state.todos = state.stack.shift()
        state.todos.unshift mtodos... if mtodos.length
      handle_multiple_call = (err) ->
        state.killed = true
        state.todos = state.stack.shift() while state.stack.length
        jump_to_error err
        run()
      jump_to_error = (err) ->
        while state.todos[0] and state.todos[0].type not in ['catch', 'next', 'promise'] then state.todos.shift()
        state.todos.err = err
      _run_ = ->
        if obj.options.domain
        then obj.options.domain.run run
        else run()
      run = (options, callback) ->
        options = state.todos.shift() unless options
        # Nothing more to do in current queue
        unless options
          obj.options.domain?.removeListener 'error', domain_on_error
          # Run is called with a callback
          if callback
            callback state.todos.err if callback
            return
          else
            if not state.killed and state.stack.length is 0 and state.todos.err and state.todos.throw_if_error
              obj.emit 'error', state.todos.err
              throw state.todos.err unless obj.listenerCount() is 0
          if state.stack.length is 0
            obj.emit 'end', level: 'INFO' unless state.todos.err
          return
        org_options = options
        parent_options = state.todos.options
        for k, v of parent_options
          org_options[k] = v if org_options[k] is undefined and k isnt 'log' and obj.propagation[k] is true
        options = enrich_options options
        options.original = org_options
        if options.type is 'next'
          {err, status} = state.todos
          status = status.some (status) -> not status.shy and !!status.value
          state.todos.final_err = err
          todos_reset state.todos
          options.handler?.call proxy, err, status
          run()
          return
        if options.type is 'promise'
          {err, status} = state.todos
          status = status.some (status) -> not status.shy and !!status.value
          state.todos.final_err = err
          todos_reset state.todos
          options.handler?.call proxy, err, status
          unless err
          then options.deferred.resolve status
          else options.deferred.reject err
          return
        return if state.killed
        if array.compare options.type, ['end']
          return conditions.all proxy, options
          , ->
            while state.todos[0] and state.todos[0].type not in ['next', 'promise'] then state.todos.shift()
            callback err if callback
            run()
          , (err) ->
            callback err if callback
            run()
        index = state.index_counter++
        state.depth++ if options.header
        state.headers.push options.header if options.header
        options.log message: options.header, type: 'header', index: index, depth: state.depth, headers: (header for header in state.headers) if options.header
        state.todos.status.unshift shy: options.shy, value: undefined
        state.stack.unshift state.todos
        state.todos = todos_create()
        state.todos.options = org_options
        wrap.options options, (err) ->
          do_disabled = ->
            unless options.disabled
              options.log type: 'lifecycle', message: 'disabled_false', level: 'DEBUG', index: index, depth: state.depth, error: null, status: false
              do_once()
            else
              options.log type: 'lifecycle', message: 'disabled_true', level: 'INFO', index: index, depth: state.depth, error: null, status: false
              do_callback []
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
              return do_callback [] if state.once[hash]
              state.once[hash] = true
            do_options_before()
          do_options_before = ->
            return do_intercept_before() if options.options_before
            options.before ?= []
            options.before = [options.before] unless Array.isArray options.before
            each options.before
            .call (before, next) ->
              before = normalize_options [before], 'call', false
              before = before[0]
              opts = options_before: true
              for k, v of before
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              run opts, next
            .error (err) -> do_callback [err]
            .next do_intercept_before
          do_intercept_before = ->
            return do_conditions() if options.intercepting
            each state.befores
            .call (before, next) ->
              for k, v of before then switch k
                when 'handler' then continue
                when 'type' then return next() unless array.compare v, options[k]
                else return next() unless v is options[k]
              opts = intercepting: true
              for k, v of before
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              run opts, next
            .error (err) -> do_callback [err]
            .next do_conditions
          do_conditions = ->
            conditions.all proxy, options
            , ->
              for k, v of options # Remove conditions from options
                delete options[k] if /^if.*/.test(k) or /^unless.*/.test(k)
              options.log type: 'lifecycle', message: 'conditions_passed', index: index, depth: state.depth, error: null, status: false
              do_handler()
            , (err) ->
              options.log type: 'lifecycle', message: 'conditions_failed', index: index, depth: state.depth, error: err, status: false
              do_callback [err]
          options.attempt = -1
          do_handler = ->
            options.attempt++
            do_next = ([err]) ->
              options.handler = options_handler
              options.callback = options_callback
              if err and err not instanceof Error
                err = Error 'First argument not a valid error'
                arguments[0][0] = err
              options.log message: err.message, level: 'ERROR', index: index, module: 'nikita' if err
              if err and ( options.retry is true or options.attempt < options.retry - 1 )
                options.log message: "Retry on error, attempt #{options.attempt+1}", level: 'WARN', index: index, module: 'nikita'
                return setTimeout do_handler, options.sleep
              do_intercept_after arguments...
            options.handler ?= obj.registry.get(options.type)?.handler or registry.get(options.type)?.handler
            return handle_multiple_call Error "Unregistered Middleware: #{options.type.join('.')}" unless options.handler
            options_handler = options.handler
            options_handler_length = options.handler.length
            options.handler = undefined
            options_callback = options.callback
            options.callback = undefined
            called = false
            try
              # Option to inject
              opts = {}
              # Clone first level properties
              for k, v of options then opts[k] = v
              for option, propagate of obj.propagation
                delete opts[option] if propagate is false
              # Handle deprecation
              options_handler = ( (options_handler) ->
                util.deprecate ->
                  options_handler.apply @, arguments
                , if options.deprecate is true
                then "#{options.type.join '/'} is deprecated"
                else "#{options.type.join '/'} is deprecated, use #{options.deprecate}"
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
                result = options_handler.call proxy, opts, ->
                  return if promise_returned
                  handle_async_and_promise.apply null, arguments
                if promise.is result
                  promise_returned = true
                  return handle_async_and_promise Error 'Invalid Promise: returning promise is not supported in asynchronuous mode'
              else # Sync style
                result = options_handler.call proxy, opts
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
                    unless state.todos.length
                      return setImmediate ->
                        do_next [null, status_sync]
                    loptions = state.todos.shift()
                    run loptions, (err, status) ->
                      return do_next [err] if err
                      # Discover status of all unshy children
                      status_sync = true if status and not loptions.shy
                      wait_children()
                  wait_children()
            catch err
              state.todos = []
              do_next [err]
          do_intercept_after = (args, callback) ->
            return do_options_after args if options.intercepting
            each state.afters
            .call (after, next) ->
              for k, v of after then switch k
                when 'handler' then continue
                when 'type' then return next() unless array.compare v, options[k]
                else return next() unless v is options[k]
              opts = intercepting: true
              for k, v of after
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              opts.callback_arguments = args
              run opts, next
            .error (err) -> do_callback [err]
            .next -> do_options_after args
          do_options_after = (args) ->
            return do_callback args if options.options_after
            options.after ?= []
            options.after = [options.after] unless Array.isArray options.after
            each options.after
            .call (after, next) ->
              after = normalize_options [after], 'call', false
              after = after[0]
              opts = options_after: true
              for k, v of after
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              run opts, next
            .error (err) -> do_callback [err]
            .next -> do_callback args
          do_callback = (args) ->
            state.depth-- if options.header
            state.headers.pop() if options.header
            options.log type: 'handled', index: index, depth: state.depth, error: args[0], status: args[1]
            return if state.killed
            args[0] = undefined unless args[0] # Error is undefined and not null or false
            args[1] = !!args[1] if options.status # Status is a boolean, error or not
            state.todos = state.stack.shift() if state.todos.length is 0
            jump_to_error args[0] if args[0] and not options.relax
            state.todos.throw_if_error = false if args[0] and options.callback
            # todo: we might want to log here a change of status, sth like:
            # options.log type: 'lifecycle', message: 'status', index: index, depth: state.depth, error: err, status: true if options.status and args[1] and not state.todos.status.some (satus) -> status
            state.todos.status[0].value = args[1] if options.status
            call_callback options.callback, args if options.callback
            args[0] = null if options.relax
            callback args[0], args[1] if callback
            run()
          do_disabled()
      state.properties.child = get: -> ->
        module.exports(obj.options)
      state.properties.next = get: -> ->
        state.todos.push type: 'next', handler: arguments[0]
        setImmediate _run_ if state.todos.length is 1 # Activate the pump
        proxy
      state.properties.promise = get: -> ->
        deferred = {}
        promise = new Promise (resolve, reject)->
          deferred.resolve = resolve
          deferred.reject = reject
        state.todos.push type: 'promise', deferred: deferred # handler: arguments[0],
        setImmediate _run_ if state.todos.length is 1 # Activate the pump
        promise
      state.properties.end = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'end'
        state.todos.push opts for opts in options
        setImmediate _run_ if state.todos.length is options.length # Activate the pump
        proxy
      state.properties.call = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'call'
        for opts in options
          if typeof opts.handler is 'string'
            opts.handler = path.resolve process.cwd(), opts.handler if opts.handler.substr(0, 1) is '.'
            mod = require.main.require opts.handler
            throw Error 'Array modules not yet supported' if Array.isArray mod
            mod = normalize_options [mod], 'call'
            opts.handler = mod.handler
            opts[k] ?= v for k, v of mod[0]
          throw Error 'Missing handler option' unless opts.handler
          throw Error "Invalid Handler: expect a function, got '#{opts.handler}'" unless typeof opts.handler is 'function'
        {get, values} = handle_get proxy, options
        return values if get
        state.todos.push opts for opts in options
        setImmediate _run_ if state.todos.length is options.length # Activate the pump
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
        arguments[0] = type: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = normalize_options arguments, null, false
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          state.befores.push opts
        proxy
      state.properties.after = get: -> ->
        arguments[0] = type: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = normalize_options arguments, null, false
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          state.afters.push opts
        proxy
      state.properties.status = get: -> (index) ->
        if arguments.length is 0
          return state.stack[0].status.some (status) -> not status.shy and !!status.value
        else if index is false
          value = state.stack[0].status.some (status) -> not status.shy and !!status.value
          status.value = false for status in state.stack[0].status
          return value
        else if index is true
          value = state.stack[0].status.some (status) -> not status.shy and !!status.value
          status.value = true for status in state.stack[0].status
          return value
        else
          state.stack[0].status[Math.abs index]?.value
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
      if obj.options.ssh
        if obj.options.ssh.config
          obj.store['nikita:ssh:connection'] = obj.options.ssh
          delete obj.options.ssh
        else
          proxy.ssh.open obj.options.ssh if not obj.options.no_ssh
      proxy

    module.exports.propagation =
      ssh: true
      log: true
      stdout: true
      stderr: true
      debug: true
      after: false
      before: false
      disabled: false
      domain: false
      handler: false
      header: false
      once: false
      relax: false
      shy: false
      sleep: false
      sudo: true

## Helper functions

    todos_create = ->
      todos = []
      todos_reset todos
      todos
    todos_reset = (todos) ->
      todos.err = null
      todos.status = []
      todos.throw_if_error = true
    handle_get = (proxy, options) ->
      return get: false unless options.length is 1
      if options.length is options.filter( (opts) -> opts.get is true ).length
        get = true
        values = for opts in options
          opts.handler.call proxy, opts, opts.callback
        values = values[0] if values.length is 1
      get: get, values: values

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
