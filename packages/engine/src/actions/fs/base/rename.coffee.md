
# `nikita.fs.rename`

Change the name or location of a file.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'source':
          type: 'string'
          description: """
          Location of the file to rename.
          """
        'target':
          type: 'string'
          description: """
          New name of the file.
          """
      required: ['source', 'target']

## Handler

    handler = ({config}) ->
      @execute
        cmd: "mv #{config.source} #{config.target}"
        trim: true

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        raw_output: true
      schema: schema

## Dependencies

    error = require '../../../utils/error'
