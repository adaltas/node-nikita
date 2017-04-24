
# `nikita.log.stream(options, [callback])`

Write log to the host filesystem in a user provided format.

## Options

* `archive` (boolean)   
  Save a copy of the previous logs inside a dedicated directory, default is
  "false".   
* `basedir` (string)    
  Directory where to store logs relative to the process working directory.
  Default to the "log" directory. Note, if the "archive" option is activated
  log file will be stored accessible from "./log/latest".   
* `filename` (string)   
  Name of the log file, contextually rendered with all options passed to
  the mustache templating engine. Default to "{{shortname}}.log", where 
  "shortname" is the ssh host or localhost.   
* `serializer` (object)   
  TODO...

## Source Code

    module.exports = ssh: null, handler: (options) ->
      # Validate options
      throw Error 'Missing option: "stream"' unless options.stream
      throw Error 'Missing option: "serializer"' unless options.serializer
      # Default values
      options.end ?= true
      # Events
      @call ->
        close = -> setTimeout ->
          options.stream.close() if options.end
        , 100
        @on 'text', (log) ->
          return unless options.serializer.text
          data = options.serializer.text log
          options.stream.write data if data?
        @on 'header', (log) ->
          return unless options.serializer.header
          data = options.serializer.header log
          options.stream.write data if data?
        @on 'stdin', (log) ->
          return unless options.serializer.stdin
          data = options.serializer.stdin log
          options.stream.write data if data?
        @on 'diff', (log) ->
          return unless options.serializer.diff
          data = options.serializer.diff log
          options.stream.write data if data?
        @on 'handled', (log) ->
          return unless options.serializer.handled
          data = options.serializer.handled log
          options.stream.write data if data?
        @on 'stdout_stream', (log) ->
          return unless options.serializer.stdout_stream
          data = options.serializer.stdout_stream log
          options.stream.write data if data?
        @on 'stderr', (log) ->
          return unless options.serializer.stderr
          data = options.serializer.stderr log
          options.stream.write data if data?
        @on 'end', ->
          return unless options.serializer.end
          data = options.serializer.end log
          options.stream.write data if data?
          close()
        @on 'error', (err) ->
          return unless options.serializer.error
          data = options.serializer.error log
          options.stream.write data if data?
          close()

## Dependencies

    fs = require 'fs'
    path = require 'path'
    mustache = require 'mustache'
