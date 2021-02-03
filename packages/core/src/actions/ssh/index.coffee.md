
# `nikita.ssh`

Get the ssh connection if any. The action throw the exception
"SSH_UNAVAILABLE_CONNECTION" if the "ssh" option is `true` but no SSH connection
was created and available.

## Configuration

* `ssh` (boolean)   
  Return the SSH connection if any and if true, null if false.

## Hook `on_action`

    on_action = ({metadata, config}) ->
      config.ssh = metadata.argument if metadata.argument?
      
## Schema

    schema =
      type: 'object'
      properties:
        'ssh':
          type: 'boolean'
          description: """
          Wether to return the SSH connection or not, even if there is an SSH
          connection opened and available.
          """

## Handler

    handler = ({config}) ->
      # Local execution, we dont want an SSH connection, no need to pursue
      return undefined if config.ssh is false
      conn = await @tools.find (action) ->
        action.state['nikita:ssh:connection']
      # We dont force the retrieval of a connection, returning what we found
      if conn or not config.ssh?
      then conn
      else throw utils.error 'SSH_UNAVAILABLE_CONNECTION', [
        'action was requested to return an SSH connection'
        'but none is opened and available'
      ]

## Exports

    module.exports =
      metadata:
        raw_output: true
        schema: schema
      handler: handler
      on_action: on_action

## Dependencies

    utils = require '../../utils'
