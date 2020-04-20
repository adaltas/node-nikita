
# `nikita.fs.mkdir`

Create a directory.

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
        'mode':
          oneOf: [{type: 'integer'}, {type: 'string'}]
          description: """
          Permission mode, a bit-field describing the file type and mode.
          """
        'target':
          type: 'string'
          description: """
          Location of the file from where to obtain information.
          """
        'uid':
          oneOf: [{type: 'integer'}, {type: 'string'}]
          description: """
          Unix user id.
          """
      required: ['target']

## Handler

    handler = ({config, metadata}) ->
      @log message: "Entering fs.mkdir", level: 'DEBUG', module: 'nikita/lib/fs/mkdir'
      # Convert mode into a string
      config.mode = config.mode.toString(8).substr(-4) if typeof config.mode is 'number'
      @execute
        cmd: [
          if config.uid or config.gid then 'install' else 'mkdir'
          "-m '#{config.mode}'" if config.mode
          "-o #{config.uid}" if config.uid
          "-g #{config.gid}" if config.gid
          if config.uid or config.gid then " -d #{config.target}" else "#{config.target}"
        ].join ' '
        # sudo: config.sudo
        # bash: config.bash
        # arch_chroot: config.arch_chroot

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        status: false
      schema: schema
