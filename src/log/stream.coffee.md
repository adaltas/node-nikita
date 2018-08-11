
# `nikita.log.stream`

Write log to custom destinations in a user provided format.

## Options

* `stream` (WritableStream)   
  Destination to which data is written.
* `serializer` (object)   
  An object of key value pairs where keys are the event types and the value is a
  function which must be implemented to serialize the information.

Global options can be alternatively set with the "log_stream" property.

## Source Code

    module.exports = ssh: false, handler: (options) ->
      # Obtains options from "log_stream" namespace
      options.log_stream ?= {}
      options[k] = v for k, v of options.log_stream
      # Validate options
      throw Error 'Missing option: "stream"' unless options.stream
      throw Error 'Missing option: "serializer"' unless options.serializer
      # Normalize
      options.end ?= true
      # Events
      @call ->
        close = -> setTimeout ->
          options.stream.close() if options.end
        , 100
        @on 'lifecycle', (log) ->
          return unless options.serializer.lifecycle
          data = options.serializer.lifecycle log
          options.stream.write data if data?
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
        @on 'end', (log) ->
          return unless options.serializer.end
          data = options.serializer.end log
          options.stream.write data if data?
          close()
        @on 'error', (err) ->
          return unless options.serializer.error
          data = options.serializer.error err
          options.stream.write data if data?
          close()

## Dependencies

    fs = require 'fs'
    path = require 'path'
    mustache = require 'mustache'
