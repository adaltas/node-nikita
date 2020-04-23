
# `nikita.fs.unlink`

Remove a non-directory type file.

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
      try
        # Not, error codes are arbitrary, unlink command always exit with code 1
        await @execute """
        [ ! -e '#{config.target}' ] && exit 2
        [ -d '#{config.target}' ] && exit 3
        unlink '#{config.target}'
        """
      catch err
        switch err.exit_code
          when 2 then err = errors.NIKITA_FS_UNLINK_ENOENT config: config
          when 3 then err = errors.NIKITA_FS_UNLINK_EPERM config: config
        throw err

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        raw_output: true
      schema: schema

## Errors

    errors =
      NIKITA_FS_UNLINK_ENOENT: ({config}) ->
        error 'NIKITA_FS_UNLINK_ENOENT', [
          'the file to remove does not exists,'
          "got #{JSON.stringify config.target}"
        ]
      NIKITA_FS_UNLINK_EPERM: ({config}) ->
        error 'NIKITA_FS_UNLINK_ENOENT', [
          'you do not have the permission to remove the file,'
          "got #{JSON.stringify config.target}"
        ]

## Dependencies

    error = require '../../utils/error'
