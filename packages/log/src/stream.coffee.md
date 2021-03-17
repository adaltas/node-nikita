
# `nikita.log.stream`

Write log to custom destinations in a user provided format.

## Schema

    schema =
      type: 'object'
      properties:
        'end':
          type: 'boolean'
          default: true
          description: '''
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
          description: '''
          The writable stream where to print the logs.
          '''
      required: ['serializer', 'stream']

## Handler

    handler = ({config, metadata: {position, uuid}, tools: {events}}) ->
      # Events
      close = ->
        config.stream.close() if config.end
      events.on 'diff', (log) ->
        return unless config.serializer.diff
        data = config.serializer.diff log
        config.stream.write data if data?
      events.on 'nikita:action:start', ->
        return unless config.serializer['nikita:action:start']
        data = await config.serializer['nikita:action:start'].apply null, arguments
        config.stream.write data if data?
      events.on 'text', (log) ->
        return unless config.serializer.text
        data = config.serializer.text log
        config.stream.write data if data?
      events.on 'stdin', (log) ->
        return unless config.serializer.stdin
        data = config.serializer.stdin log
        config.stream.write data if data?
      events.on 'nikita:action:end', ->
        return unless config.serializer['nikita:action:end']
        data = config.serializer['nikita:action:end'].apply null, arguments
        config.stream.write data if data?
      events.on 'stdout_stream', (log) ->
        return unless config.serializer.stdout_stream
        data = config.serializer.stdout_stream log
        config.stream.write data if data?
      events.on 'nikita:resolved', ({action}) ->
        if config.serializer['nikita:resolved']
          data = config.serializer['nikita:resolved'].apply null, arguments
          config.stream.write data if data?
        close()
      events.on 'nikita:rejected', ({action}) ->
        if config.serializer['nikita:rejected']
          data = config.serializer['nikita:rejected'].apply null, arguments
          config.stream.write data if data?
        close()
      null

## Exports

    module.exports =
      ssh: false
      handler: handler
      metadata:
        schema: schema

## Dependencies

    fs = require 'fs'
    path = require 'path'
