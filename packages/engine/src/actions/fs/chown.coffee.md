
# `nikita.fs.chown`

Change ownership of a file.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'gid':
          oneOf: [{type: 'integer'}, {type: 'string'}]
          description: """
          Unix group id.
          """
        'target':
          type: 'string'
          description: """
          Location of the file which permissions will change.
          """
        'uid':
          oneOf: [{type: 'integer'}, {type: 'string'}]
          description: """
          Unix user id.
          """
      required: ['target']

## Handler

    handler = ({config, metadata}) ->
      @log message: "Entering fs.chown", level: 'DEBUG', module: 'nikita/lib/fs/chown'
      # Normalization
      config.uid = null if config.uid is false
      config.gid = null if config.gid is false
      # Validation
      throw Error "Missing one of uid or gid option" unless config.uid? or config.gid?
      @execute
        cmd: """
        [ -n '#{if config.uid? then config.uid else ''}' ] && chown #{config.uid} #{config.target}
        [ -n '#{if config.gid? then config.gid else ''}' ] && chgrp #{config.gid} #{config.target}
        """

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
