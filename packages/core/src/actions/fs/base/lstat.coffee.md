
# `nikita.fs.base.lstat`

Retrieve file information. If path is a symbolic link, then the link itself is
stated, not the file that it refers to.

## Schema

    schema =
      type: 'object'
      properties:
        'target':
          type: 'string'
          description: '''
          Location of the file from where to obtain information.
          '''
      required: ['target']

## Handler

    handler = ({config}) ->
      await @fs.base.stat
        target: config.target
        dereference: false

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        schema: schema
