
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

## Handler

    handler = ({config, parent: {state}, tools: {log}}) ->
      log message: "Entering ssh.close", level: 'DEBUG', module: 'nikita/lib/ssh/close'
      # Retrieve connection from parameters or state
      conn = if config.ssh
      then config.ssh
      else state['nikita:ssh:connection']
      # Exit unless their is a connection to close
      return false unless conn
      # Exit if the connection is already close
      return false unless conn._sshstream?.writable and conn._sock?.writable
      # Terminate the connection
      new Promise (resolve, reject) ->
        conn.end()
        conn.on 'error', reject
        conn.on 'end', ->
          delete state['nikita:ssh:connection']
          resolve true

## Exports

    module.exports =
      handler: handler
      metadata:
        schema: schema
