
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

    handler = ({options, parent: {state}}) ->
      # throw Error "Invalid Option: ssh must be a boolean value or null or undefined, got #{JSON.stringify options.ssh}" if options.ssh? and not typeof options.ssh is 'boolean'
      throw error 'SSH_UNAVAILABLE_CONNECTION', [
        'action was requested to return an SSH connection'
        'but none is opened and available'
      ] if options.ssh is true and not state['nikita:ssh:connection']
      return undefined if options.ssh is false
      return state['nikita:ssh:connection']

## Exports

    module.exports =
      metadata: raw_output: true
      handler: handler
      on_action: on_action
      schema: schema

## Dependencies

    error = require '../../utils/error'
