
# `nikita.fs.unlink`

Delete a name and possibly the file it refers to.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'target':
          type: 'string'
          description: """
          Location of the file to remove.
          """
      required: ['target']

## Handler

    handler = ({config, metadata}) ->
      @log message: "Entering fs.unlink", level: 'DEBUG', module: 'nikita/lib/fs/unlink'
      @execute
        cmd: "unlink #{config.target}"

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

    error = require '../../utils/error'
