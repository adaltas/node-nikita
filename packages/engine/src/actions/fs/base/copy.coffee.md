
# `nikita.fs.copy`

Change permissions of a file.

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
          Source file to be copied.
          """
        'target':
          type: 'string'
          description: """
          Destination file where to copy the source file.
          """
      required: ['source', 'target']

## Handler

    handler = ({config}) ->
      @log message: "Entering fs.copy", level: 'DEBUG', module: 'nikita/lib/fs/copy'
      try
        await @execute """
          [ ! -d `dirname "#{config.target}"` ] && exit 2
          cp #{config.source} #{config.target}
          """
      catch err
        if err.exit_code is 2
          err = errors.NIKITA_FS_COPY_TARGET_ENOENT config: config, err: err
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
      NIKITA_FS_COPY_TARGET_ENOENT: ({config, err}) ->
        error 'NIKITA_FS_COPY_TARGET_ENOENT', [
          'target parent directory does not exists or is not a directory,'
          "got #{JSON.stringify config.target}"
        ],
          exit_code: err.exit_code
          errno: -2
          syscall: 'open'
          path: config.target

## Dependencies

    error = require '../../../utils/error'
