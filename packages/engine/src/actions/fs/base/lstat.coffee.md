
# `nikita.fs.lstat`

Retrieve file information. If path is a symbolic link, then the link itself is
stated, not the file that it refers to.

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
          Location of the file from where to obtain information.
          """
      required: ['target']

## Handler

    handler = ({config}) ->
      @log message: "Entering fs.lstat", level: 'DEBUG', module: 'nikita/lib/fs/lstat'
      @fs.base.stat
        target: config.target
        dereference: false

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        raw_output: true
      schema: schema
