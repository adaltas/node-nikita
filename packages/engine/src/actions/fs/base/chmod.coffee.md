
# `nikita.fs.chmod`

Change permissions of a file.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'mode':
          oneOf: [{type: 'integer'}, {type: 'string'}]
          default: 0o644
          description: """
          Location of the file which ownership will change.
          """
        'target':
          type: 'string'
          description: """
          Destination file where to copy the source file.
          """
      required: ['mode', 'target']

## Handler

    handler = ({config, metadata}) ->
      @log message: "Entering fs.chmod", level: 'DEBUG', module: 'nikita/lib/fs/chmod'
      config.mode = config.mode.toString(8).substr(-4) if typeof config.mode is 'number'
      @execute
        cmd: "chmod #{config.mode} #{config.target}"

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
