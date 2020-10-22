
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
          File mode. Modes may be absolute or symbolic. An absolute mode is
          an octal number. A symbolic mode is a string with a particular syntax
          describing `who`, `op` and `perm` symbols.
          """
        'target':
          type: 'string'
          description: """
          Location of the file which permission will change.
          """
      required: ['mode', 'target']

## Handler

    handler = ({config}) ->
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
