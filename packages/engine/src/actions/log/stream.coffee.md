
# `nikita.log.stream`

Write log to custom destinations in a user provided format.

## Schema

    schema =
      type: 'object'
      properties:
        'end':
          type: 'boolean'
          description: """
          Close the writable stream with the session is finished or stoped on
          error.
          """
        'serializer':
          type: 'object'
          description: """
          An object of key value pairs where keys are the event types and the
          value is a function which must be implemented to serialize the
          information.
          """
          patternProperties:
            '.*': typeof: 'function'
          additionalProperties: false
        'stream':
          instanceof: 'Object' # WritableStream
          description: """
          Destination to which data is written.
          """

## Handler

    handler = ({config, operations: {events}}) ->
      # Validate config
      throw Error 'Missing option: "stream"' unless config.stream
      throw Error 'Missing option: "serializer"' unless config.serializer
      # Normalize
      config.end ?= true
      # Events
      close = -> setTimeout ->
        config.stream.close() if config.end
      , 100
      events.on 'nikita:action:start', (act) ->
        return unless config.serializer['nikita:action:start']
        data = await config.serializer['nikita:action:start'] act
        config.stream.write data if data?
      # events.on 'lifecycle', (log) ->
      #   return unless config.serializer.lifecycle
      #   data = config.serializer.lifecycle log
      #   config.stream.write data if data?
      events.on 'text', (log) ->
        return unless config.serializer.text
        data = config.serializer.text log
        config.stream.write data if data?
      # events.on 'header', (log) ->
      #   return unless config.serializer.header
      #   data = config.serializer.header log
      #   config.stream.write data if data?
      events.on 'stdin', (log) ->
        return unless config.serializer.stdin
        data = config.serializer.stdin log
        config.stream.write data if data?
      # events.on 'diff', (log) ->
      #   return unless config.serializer.diff
      #   data = config.serializer.diff log
      #   config.stream.write data if data?
      events.on 'nikita:action:end', ->
        return unless config.serializer['nikita:action:end']
        data = config.serializer['nikita:action:end'].apply null, arguments
        config.stream.write data if data?
      events.on 'stdout_stream', (log) ->
        return unless config.serializer.stdout_stream
        data = config.serializer.stdout_stream log
        config.stream.write data if data?
      # events.on 'stderr', (log) ->
      #   return unless config.serializer.stderr
      #   data = config.serializer.stderr log
      #   config.stream.write data if data?
      events.on 'nikita:session:resolved', ->
        if config.serializer['nikita:session:resolved']
          data = config.serializer['nikita:session:resolved'].apply null, arguments
          config.stream.write data if data?
        close()
      events.on 'nikita:session:rejected', (err) ->
        if config.serializer['nikita:session:rejected']
          data = config.serializer['nikita:session:rejected'].apply null, arguments
          config.stream.write data if data?
        close()
      null

## Exports

    module.exports =
      ssh: false
      handler: handler
      schema: schema

## Dependencies

    fs = require 'fs'
    path = require 'path'
