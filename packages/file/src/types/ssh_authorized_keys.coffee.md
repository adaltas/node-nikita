
`nikita.file.types.ssh_authorized_keys`

Note, due to the restrictive permission imposed by sshd on the parent directory,
this action will not attempt to create nor modify the parent directory and will
throw an Error if it does not exists.

## Schema

    schema =
      type: 'object'
      properties:
        'gid':
          type: 'string'
          description: """
          File group name or group id.
          """
        'keys':
          type: 'array'
          description: """
          Array containing the public keys.
          """
        'merge':
          type: 'boolean'
          description: """
          Read the target if it exists and merge its content.
          """
        'mode':
          type: 'string'
          description: """
          File mode (permission and sticky bits), default to `0o0644`, in the
          form of `{mode: 0o0744}` or `{mode: "0744"}`.
          """
        'target':
          type: 'string'
          description: """
          File to write, default to "/etc/pacman.conf".
          """
        'uid':
          type: 'string'
          description: """
          File user name or user id.
          """
      required: ['target', 'keys']

## Handler

    handler = ({config}) ->
      @fs.assert
        target: path.dirname config.target
      if config.merge
        @file
          target: config.target
          write: for key in config.keys
            match: new RegExp ".*#{utils.regexp.escape key}.*", 'mg'
            replace: key
            append: true
          uid: config.uid
          gid: config.gid
          mode: config.mode
          eof: true
      else
        @file
          target: config.target
          content: config.keys.join '\n'
          uid: config.uid
          gid: config.gid
          mode: config.mode
          eof: true
      

## Exports

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    path = require 'path'
    utils = require '../utils'
