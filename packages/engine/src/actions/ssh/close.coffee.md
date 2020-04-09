
# `nikita.ssh.close`

Close the existing connection if any.

## Configuration

* `ssh` (boolean)   
  Return the SSH connection if any and if true, null if false.

## Schema

    schema =
      type: 'object'
      properties:
        'ssh':
          instanceof: 'Object'
          description: """
          The SSH connection to close, default to currently active SSH
          connection avaible to the action.
          """

## Source code

    handler = ({config, parent: {state}}) ->
      @log message: "Entering ssh.close", level: 'DEBUG', module: 'nikita/lib/ssh/close'
      return false unless state['nikita:ssh:connection']
      conn = if config.ssh
      then config.ssh
      else state['nikita:ssh:connection']
      new Promise (resolve, reject) ->
        conn.end()
        conn.on 'error', reject
        conn.on 'end', ->
          delete state['nikita:ssh:connection']
          resolve true

## Exports

    module.exports =
      handler: handler
      schema: schema
