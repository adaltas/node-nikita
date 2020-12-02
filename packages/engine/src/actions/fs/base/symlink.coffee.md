
# `nikita.fs.base.symlink`

Delete a name and possibly the file it refers to.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'source':
          oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
          description: """
          Location of the file to reference.
          """
        'target':
          oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
          description: """
          Destination of the link to create.
          """
      required: ['source', 'target']

## Handler

    handler = ({config}) ->
      @execute
        command: """
        ln -sf #{config.source} #{config.target}
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
