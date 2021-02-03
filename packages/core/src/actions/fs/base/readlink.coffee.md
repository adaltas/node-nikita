
# `nikita.fs.base.readlink`

Read a link to retrieve its destination path.

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
          Location of the link to read.
          """
      required: ['target']

## Handler

    handler = ({config}) ->
      {stdout} = await @execute
        command: "readlink #{config.target}"
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
