
# `mecano.log.cli(options, [callback])`

Write log to the host filesystem in a user provided format.

## Options

*   `stdout` (stream.Writable)   
*   `end` (boolean)    
*   `enabled` (boolean)    
*   `separator` (string)    
*   `depth` (number|boolean)    

## Source Code

    module.exports = ssh: null, handler: (options) ->
      # Normalize
      options.enabled ?= options.argument if options.argument?
      options.enabled ?= true
      options.stream ?= process.stdout
      options.end ?= false
      options.separator ?= ' # '
      options.depth ?= false
      # Events
      @call options, log_fs, serializer:
        'diff': null
        'end': ->
          "FINISH\n"
        'error': (err) ->
          "ERROR"
        'header': (log) ->
          return unless options.enabled
          host = if options.ssh then options.ssh.config.host else 'localhost'
          return if options.depth and options.depth < log.headers.length
          "#{host}  #{log.headers.join(options.separator)}"
        'stdin': null
        'stderr': null
        'stdout': null
        'text': null

## Dependencies

    log_fs = require './fs'
