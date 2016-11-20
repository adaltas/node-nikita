
# Mecano Context

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
      obj.propagated_options ?= []
      for option in module.exports.propagated_options then obj.propagated_options.push option
      store = {}
      properties = {}
      stack = []
      todos = todos_create()
      befores = []
      afters = []
      depth = 0
      headers = []
      once = {}
      killed = false
      index_counter = 0
      obj.options.domain =  domain.create() if obj.options.domain is true
      domain_on_error = (err) ->
        err.message = "Invalid State Error [#{err.message}]"
        handle_multiple_call err
      obj.options.domain?.on 'error', domain_on_error
      proxy = new Proxy obj,
        has: (target, name) ->
          target[name]? or target.registry.registered(proxy.type)? or registry.registered(name)?
        get: (target, name) ->
          return target[name] if target[name]?
          return target[name] if name in ['domain', '_events', '_maxListeners']
          proxy.type = []
          proxy.type.push name
          get_proxy_builder = ->
            builder = ->
              # Insert handler before callback or at the end of arguments
              handler = target.registry.get(proxy.type) or registry.get(proxy.type)
              args = [].slice.call(arguments)
              args.unshift handler
              options = normalize_options args, proxy.type
              proxy.type = []
              todos.push opts for opts in options
              setImmediate _run_ if todos.length is options.length # Activate the pump
              proxy
            new Proxy builder,
              get: (target, name) ->
                return target[name] if target[name]?
                proxy.type.push name
                get_proxy_builder()
          get_proxy_builder()
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
        for opts, i in options
          # Clone
          options[i] = {}
          options[i][k] = v for k, v of opts
          opts = options[i]
          # Argument
          if type is 'call' and not opts.handler #and typeof opts.argument is 'function'
            opts.handler = opts.argument
            opts.argument = undefined
          # Enrich
          if opts.destination
            console.log 'Use options target instead of destination' unless called_deprecate_destination
            called_deprecate_destination = true
            opts.target ?= opts.destination
          if opts.local_source
            console.log 'Use options local instead of local_source' unless called_deprecate_local_source
            called_deprecate_local_source = true
            opts.local ?= opts.local_source
          opts.type = type if type
          opts.type = [opts.type] unless Array.isArray opts.type
          opts.handler ?= handler if handler
          opts.callback ?= callback if callback
          opts.user_args = true if enrich and opts.callback?.length > 2
          opts.store ?= store if enrich and store
          opts.once = ['handler'] if opts.once is true
          delete opts.once if opts.once is false
          opts.once = opts.once.sort() if Array.isArray opts.once
          opts.wait ?= 3000 # Wait 3s between retry
          # Validation
          jump_to_error Error "Invalid options wait, got #{JSON.stringify opts.wait}" unless typeof opts.wait is 'number' and opts.wait >= 0
        options
      enrich_options = (user_options) ->
        user_options.enriched = true
        global_options = obj.options
        parent_options = todos.options
        options = {}
        for k, v of user_options then options[k] = user_options[k]
        for k, v of parent_options
          options[k] = v if options[k] is undefined and k in obj.propagated_options
        for k, v of global_options
          options[k] = v if options[k] is undefined
        unless options.log?.dont
          if options.log and not Array.isArray options.log
            _logs = [options.log]
          else if not options.log
            _logs = []
        log_disabled = true if options.log is false
        options.log = [] if log_disabled
        options.log = [] if options.log?._mecano_ # not clean but no better way to detect user provided option with the one from mecano
        options.log ?= []
        options.log = [options.log] unless Array.isArray options.log
        _logs = options.log
        if options.debug
          _logs.push (log) ->
            return if log.type in ['stdout', 'stderr']
            msg = if log.message?.toString? then log.message.toString() else log.message
            msg = "[#{log.total_depth}.#{log.level} #{log.module}] #{JSON.stringify msg}"
            msg = switch log.type
              when 'stdout_stream' then "\x1b[36m#{msg}\x1b[39m"
              when 'stderr_stream' then "\x1b[35m#{msg}\x1b[39m"
              else "\x1b[32m#{msg}\x1b[39m"
            process.stdout.write "#{msg}\n" # todo: switch with stderr
        options.log = (log) ->
          log = message: log if typeof log is 'string'
          log.level ?= 'INFO'
          log.time ?= Date.now()
          log.module ?= undefined
          log.header_depth ?= depth
          log.headers ?= header for header in headers
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
          _log log for _log in _logs
          obj.emit? log.type, log unless log_disabled
        options.log._mecano_ = true
        options
      call_callback = (fn, args) ->
        stack.unshift todos
        todos = todos_create()
        try
          fn.apply proxy, args
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
        while todos[0] and todos[0].type not in ['catch', 'then'] then todos.shift()
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
        org_options = options
        options = enrich_options options
        if options.type is 'then'
          {err, status} = todos
          status = status.some (status) -> not status.shy and !!status.value
          todos.final_err = err
          todos_reset todos
          options.handler?.call proxy, err, status
          run()
          return
        return if killed
        if array.compare options.type, ['end']
          return conditions.all proxy, options
          , (err) ->
            callback err if callback
            run()
          , ->
            while todos[0] and todos[0].type isnt 'then' then todos.shift()
            callback err if callback
            run()
        index = index_counter++
        depth++ if options.header
        headers.push options.header if options.header
        options.log message: options.header, type: 'header', index: index, depth: depth, headers: (header for header in headers) if options.header
        todos.status.unshift shy: options.shy, value: undefined
        stack.unshift todos
        todos = todos_create()
        todos.options = org_options
        wrap.options options, (err) ->
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
                throw Error "Invalid Type Option Once: #{JSON.stringify options.once}"
              return do_callback [] if once[hash]
              once[hash] = true
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
            .then do_intercept_before
          do_intercept_before = ->
            return do_conditions() if options.intercept_before
            each befores
            .call (before, next) ->
              for k, v of before then switch k
                when 'handler' then continue
                when 'type' then return next() unless array.compare v, options[k]
                else return next() unless v is options[k]
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
              do_handler()
          options.attempt = -1
          do_handler = ->
            options.attempt++
            do_next = ([err]) ->
              options.handler = options_handler
              options.callback = options_callback
              if err and err not instanceof Error
                err = Error 'First argument not a valid error'
                arguments[0][0] = err
              options.log message: err.message, level: 'ERROR', index: index, module: 'mecano' if err
              if err and options.attempt < options.retry - 1
                options.log message: "Retry on error, attempt #{options.attempt+1}", level: 'WARN', index: index, module: 'mecano'
                return setTimeout do_handler, options.wait
              do_intercept_after arguments...
            options.handler ?= obj.registry.get(options.type) or registry.get(options.type)
            return handle_multiple_call Error "Unregistered Handler: #{options.type}" unless options.handler
            options_handler = options.handler
            options.handler = undefined
            options_callback = options.callback
            options.callback = undefined
            called = false
            try
              opts = {}
              for k, v of options
                opts[k] = v
              if options_handler.length is 2 # Async style
                options_handler.call proxy, opts, ->
                  return if killed
                  return handle_multiple_call Error 'Multiple call detected' if called
                  called = true
                  args = [].slice.call(arguments, 0)
                  setImmediate ->
                    do_next args
              else # Sync style
                options_handler.call proxy, opts
                return if killed
                return handle_multiple_call Error 'Multiple call detected' if called
                called = true
                status_sync = false
                wait_children = ->
                  unless todos.length
                    return setImmediate ->
                      do_next [null, status_sync]
                  loptions = todos.shift()
                  run loptions, (err, status) ->
                    return do_next [err] if err
                    # Discover status of all unshy children
                    status_sync = true if status and not loptions.shy
                    wait_children()
                wait_children()
            catch err
              todos = []
              do_next [err]
          do_intercept_after = (args, callback) ->
            return do_options_after args if options.intercept_after
            each afters
            .call (after, next) ->
              for k, v of after then switch k
                when 'handler' then continue
                when 'type' then return next() unless array.compare v, options[k]
                else return next() unless v is options[k]
              opts = intercept_after: true
              for k, v of after
                opts[k] = v
              for k, v of options
                continue if k in ['handler', 'callback']
                opts[k] ?= v
              opts.callback_arguments = args
              run opts, next
            .error (err) -> do_callback [err]
            .then -> do_options_after args
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
            .then -> do_callback args
          do_callback = (args) ->
            depth-- if options.header
            headers.pop() if options.header
            options.log type: 'handled', index: index, depth: depth, error: args[0], status: args[1]
            return if killed
            args[0] = undefined unless args[0] # Error is undefined and not null or false
            args[1] = !!args[1] # Status is a boolean, error or not
            todos = stack.shift() if todos.length is 0
            jump_to_error args[0] if args[0] and not options.relax
            todos.throw_if_error = false if args[0] and options.callback
            todos.status[0].value = args[1]
            call_callback options.callback, args if options.callback
            args[0] = null if options.relax
            callback args[0], args[1] if callback
            run()
          do_once()
      properties.child = get: -> ->
        module.exports(obj.options)
      properties.then = get: -> ->
        todos.push type: 'then', handler: arguments[0]
        setImmediate _run_ if todos.length is 1 # Activate the pump
        proxy
      properties.end = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'end'
        todos.push opts for opts in options
        setImmediate _run_ if todos.length is options.length # Activate the pump
        proxy
      properties.call = get: -> ->
        args = [].slice.call(arguments)
        options = normalize_options args, 'call'
        for opts in options
          if typeof opts.handler is 'string'
            mod = require.main.require opts.handler
            throw Error 'Array modules not yet supported' if Array.isArray mod
            mod = normalize_options [mod], 'call'
            opts.handler = mod.handler
            opts[k] ?= v for k, v of mod[0]
          throw Error 'Missing handler option' unless opts.handler
          throw Error "Handler not a function, got '#{opts.handler}'" unless typeof opts.handler is 'function'
        todos.push opts for opts in options
        setImmediate _run_ if todos.length is options.length # Activate the pump
        proxy
      properties.each = get: -> ->
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
      properties.before = get: -> ->
        arguments[0] = type: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = normalize_options arguments, null, false
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          befores.push opts
        proxy
      properties.after = get: -> ->
        arguments[0] = type: arguments[0] if typeof arguments[0] is 'string' or Array.isArray(arguments[0])
        options = normalize_options arguments, null, false
        for opts in options
          throw Error "Invalid handler #{JSON.stringify opts.handler}" unless typeof opts.handler is 'function'
          afters.push opts
        proxy
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
      Object.defineProperties obj, properties
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
      proxy

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

## Dependencies

    registry = require './registry'
    domain = require 'domain'
    each = require 'each'
    array = require './misc/array'
    conditions = require './misc/conditions'
    wrap = require './misc/wrap'
    string = require './misc/string'
    {merge} = require './misc'
    {EventEmitter} = require 'events'
