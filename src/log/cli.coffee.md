
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
      options.divider ?= ' : '
      options.depth ?= false
      options.pad ?= {}
      options.separator = host: options.separator, header: options.separator if typeof options.separator is 'string'
      options.separator ?= {}
      options.separator.host ?= unless options.pad.host? then '   ' else ''
      options.separator.header ?= unless options.pad.header? then '   ' else ''
      # Events
      ids = {}
      @call options, stream, serializer:
        'diff': null
        'end': ->
          "FINISH\n"
        'error': (err) ->
          "ERROR"
        'header': (log) ->
          return unless options.enabled
          return if options.depth and options.depth < log.headers.length
          ids[log.index] = log
          null
        "handled": (log) ->
          status = if log.status then '+' else '-'
          log = ids[log.index]
          return null unless log
          delete ids[log.index]
          host = if options.ssh then options.ssh.config.host else 'localhost'
          header = log.headers.join(options.divider)
          # Padding
          host = pad host, options.pad.host if options.pad.host
          header = pad header, options.pad.header if options.pad.header
          "#{host}#{options.separator.host}#{header}#{options.separator.header}#{status}\n"
        'stdin': null
        'stderr': null
        'stdout': null
        'text': null

## Dependencies

    pad = require 'pad'
    stream = require './stream'
