
# `nikita.fs.readlink`

Read a link to retrieve its destination path.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## schema

    schema =
      type: 'object'
      properties:
        'target':
          oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
          description: """
          Location of the link to read.
          """
      required: ['target']

## Handler

    handler = ({config}) ->
      @log message: "Entering fs.readlink", level: 'DEBUG', module: 'nikita/lib/fs/readlink'
      {stdout} = await @execute
        cmd: "readlink #{config.target}"
      target: stdout.trim()

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        raw_output: true
      schema: schema
