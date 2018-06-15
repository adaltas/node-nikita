
# `nikita.log(options)`

Send a log message.

## Options


* `level` (string)   
  Set the message log level, recommended values are 'DEBUG', 'INFO', 'WARN' and
  'ERROR'.
* `module` (string)   
  The module name from where the message was issued.
* `time` (integer)   
  The timestamp associated with the message, default to the current timestamp
  when the log action is called.

## Source Code

    module.exports = ssh: false, get: true, cascade:
      action: false
      cascade: false
      # disabled: false
      get: false
      # handler: false
      # index: false
      # level: false
      # line: false
      log: false # TODO shall be removed after the deprecation of log
      # parent: false
      retry: false
      ssh: false
      shy: true
      # status: false
    , handler: (options) ->
      # Options
      options.message = options.argument if options.argument?
      options.level ?= 'INFO'
      options.time ?= Date.now()
      options.module ?= undefined
      # options.headers ?= header for header in state.headers
      # options.depth ?= state.stack.length
      options.type ?= 'text'
      options.depth = options.depth - 1
      # log.shy ?= options.shy
      # args = if 1 <= arguments.length then [].slice.call(arguments, 0) else []
      stackTrace = require 'stack-trace'
      frame = stackTrace.get()[1]
      file = path.basename(frame.getFileName())
      line = frame.getLineNumber()
      # method = frame.getFunctionName()
      options.file = file
      options.line = line
      parent = options.parent
      delete options.parent
      return if parent?.log is false
      if parent?.log
         parent?.log options
      if options.debug
        if options.type in ['text', 'stdin', 'stdout_stream', 'stderr_stream']
          unless options.type in ['stdout_stream', 'stderr_stream'] and options.message is null
            msg = if options.message?.toString? then options.message.toString() else options.message
            msg = "[#{options.depth}.#{options.level} #{options.module}] #{JSON.stringify msg}"
            msg = switch options.type
              when 'stdin' then "\x1b[33m#{msg}\x1b[39m"
              when 'stdout_stream' then "\x1b[36m#{msg}\x1b[39m"
              when 'stderr_stream' then "\x1b[35m#{msg}\x1b[39m"
              else "\x1b[32m#{msg}\x1b[39m"
            if options.debug is 'stdout'
              process.stdout.write "#{msg}\n"
            else
              process.stderr.write "#{msg}\n"
      @emit options.type, options #unless log_disabled

## Dependencies

    path = require 'path'
