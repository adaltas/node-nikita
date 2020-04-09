
# `nikita.ssh`

Get the ssh connection if any. The action throw the exception
"SSH_UNAVAILABLE_CONNECTION" if the "ssh" option is `true` but no SSH connection
was created and available.

## Options

* `ssh` (boolean)   
  Return the SSH connection if any and if true, null if false.

## Hook `on_action`

    on_action = ({metadata, options}) ->
      options.ssh = metadata.argument if metadata.argument?
      
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

## Source code

    handler = ({options, parent}) ->
      # Local execution, we dont want an SSH connection, no need to pursue
      return undefined if options.ssh is false
      conn = await @operations.find (action) ->
        action.state['nikita:ssh:connection']
      # We dont force the retrieval of a connection, returning what we found
      if conn or not options.ssh?
      then conn
      else throw error 'SSH_UNAVAILABLE_CONNECTION', [
        'action was requested to return an SSH connection'
        'but none is opened and available'
      ]

## Exports

    module.exports =
      metadata: raw_output: true
      handler: handler
      on_action: on_action
      schema: schema

## Dependencies

    error = require '../../utils/error'
