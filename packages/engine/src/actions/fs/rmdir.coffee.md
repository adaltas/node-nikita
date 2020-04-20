
# `nikita.fs.rmdir`

Delete a directory.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## schema

    schema =
      type: 'object'
      properties:
        'target':
          oneOf: [{type: 'string'}, 'instanceof': 'Buffer']
          description: """
          Location of the directory to remove.
          """
      required: ['target']

## Handler

    handler = ({config, metadata}) ->
      @log message: "Entering fs.rmdir", level: 'DEBUG', module: 'nikita/lib/fs/rmdir'
      try
        await @execute
          cmd: """
          [ ! -d '#{config.target}' ] && exit 2
          rmdir '#{config.target}'
          """
          # sudo: config.sudo
          # bash: config.bash
          # arch_chroot: config.arch_chroot
        @log message: "Directory successfully removed", level: 'INFO', module: 'nikita/lib/fs/write'
      catch err
        @log message: "Fail to remove directory", level: 'ERROR', module: 'nikita/lib/fs/write'
        if err.exit_code is 2
          throw error 'NIKITA_FS_RMDIR_TARGET_ENOENT', [
            'fail to remove a directory, target is not a directory,'
            "got #{JSON.stringify config.target}"
          ],
            exit_code: err.exit_code
            errno: -2
            syscall: 'rmdir'
            path: config.target
        else
          throw err

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        status: false
      schema: schema

## Dependencies

    error = require '../../utils/error'
