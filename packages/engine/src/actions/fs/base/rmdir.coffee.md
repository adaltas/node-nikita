
# `nikita.fs.base.rmdir`

Delete a directory.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'target':
          oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
          description: """
          Location of the directory to remove.
          """
      required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      try
        await @execute
          command: """
          [ ! -d '#{config.target}' ] && exit 2
          rmdir '#{config.target}'
          """
        log message: "Directory successfully removed", level: 'INFO', module: 'nikita/lib/fs/write'
      catch err
        err = errors.NIKITA_FS_RMDIR_TARGET_ENOENT config: config, err: err if err.exit_code is 2
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
      NIKITA_FS_RMDIR_TARGET_ENOENT: ({config, err}) ->
        utils.error 'NIKITA_FS_RMDIR_TARGET_ENOENT', [
          'fail to remove a directory, target is not a directory,'
          "got #{JSON.stringify config.target}"
        ],
          exit_code: err.exit_code
          errno: -2
          syscall: 'rmdir'
          path: config.target

## Dependencies

    utils = require '../../../utils'
