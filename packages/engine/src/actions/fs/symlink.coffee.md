
# `nikita.fs.symlink`

Delete a name and possibly the file it refers to.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## schema

    schema =
      type: 'object'
      properties:
        'source':
          oneOf: [{type: 'string'}, 'instanceof': 'Buffer']
          description: """
          Location of the file to reference.
          """
        'target':
          oneOf: [{type: 'string'}, 'instanceof': 'Buffer']
          description: """
          Destination of the link to create.
          """
      required: ['source', 'target']

## Handler

    handler = ({config, metadata}) ->
      @log message: "Entering fs.symlink", level: 'DEBUG', module: 'nikita/lib/fs/symlink'
      @execute
        cmd: "ln -sf #{config.source} #{config.target}"
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
