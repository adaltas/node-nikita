
# `nikita.log`

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
      get: false
      retry: false
      ssh: false
      shy: true
    , handler: ({options, metadata, parent}) ->
      # Options
      log = {}
      log.message = metadata.argument or options.message #or parent?.metadata.argument
      log.level = options.level or 'INFO'
      log.time ?= Date.now()
      log.index ?= options.index
      log.module = options.module
      log.type = options.type or 'text'
      log.depth = metadata.depth - 1
      log.metadata = metadata
      log.options = options
      log.parent = parent
      frame = stackTrace.get()[1]
      file = path.basename(frame.getFileName())
      line = frame.getLineNumber()
      log.file = file
      log.line = line
      if parent?.metadata.debug
        if log.type in ['text', 'stdin', 'stdout_stream', 'stderr_stream']
          unless log.type in ['stdout_stream', 'stderr_stream'] and log.message is null
            msg = if typeof log.message is 'string' then log.message.trim()
            else if typeof log.message is 'number' then log.message
            else if log.message?.toString? then log.message.toString().trim()
            else JSON.stringify log.message
            msg = "[#{log.depth}.#{log.level} #{log.module}] #{ msg}"
            msg = switch log.type
              when 'stdin' then "\x1b[33m#{msg}\x1b[39m"
              when 'stdout_stream' then "\x1b[36m#{msg}\x1b[39m"
              when 'stderr_stream' then "\x1b[35m#{msg}\x1b[39m"
              else "\x1b[32m#{msg}\x1b[39m"
            if parent?.metadata.debug is 'stdout'
              process.stdout.write "#{msg}\n"
            else
              process.stderr.write "#{msg}\n"
      if typeof metadata.log is 'function'
        parent?.metadata?.log log
      else
        return if parent?.metadata?.log is false
      @emit log.type, log #unless log_disabled

## Dependencies

    path = require 'path'
    stackTrace = require 'stack-trace' # dec 2019, was required at runtime, dont know why
