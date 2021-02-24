
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
      required: ['ssh']

## Handler

    handler = ({config}) ->
      # Exit if the connection is already close
      return false unless config.ssh._sshstream?.writable and config.ssh._sock?.writable
      # Terminate the connection
      new Promise (resolve, reject) ->
        config.ssh.end()
        config.ssh.on 'error', reject
        config.ssh.on 'end', ->
          resolve true

## Exports

    module.exports =
      handler: handler
      metadata:
        schema: schema
