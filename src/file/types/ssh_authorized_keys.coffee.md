
`nikita.file.types.ssh_authorized_keys`

Note, due to the restrictive permission imposed by sshd on the parent directory,
this action will not attempt to create nor modify the parent directory and will
throw an Error if it does not exists.

## Options

* `gid`   
  File group name or group id.
* `keys`   
  Array containing the public keys.
* `merge` (string)   
  File to write, default to "/etc/pacman.conf".
* `mode`   
  File mode (permission and sticky bits), default to `0o0644`, in the form of
`{mode: 0o0744}` or `{mode: "0744"}`.
* `target` (string)   
  File to write, default to "/etc/pacman.conf".
* `uid`   
  File user name or user id.

## Source Code

    module.exports = ({options}) ->
      throw Error "Required Option: target, got #{JSON.stringify options.target}" unless options.target
      throw Error "Required Option: keys, got #{JSON.stringify options.keys}" unless options.keys
      throw Error "Invallid Option: keys must be an array, got #{JSON.stringify options.keys}" unless Array.isArray options.keys
      @file.assert
        target: path.dirname options.target
      @file
        unless: options.merge
        target: options.target
        content: options.keys.join '\n'
        uid: options.uid
        gid: options.gid
        mode: options.mode
        eof: true
      @file
        if: options.merge
        target: options.target
        write: for key in options.keys
          match: new RegExp ".*#{misc.regexp.escape key}.*", 'mg'
          replace: key
          append: true
        uid: options.uid
        gid: options.gid
        mode: options.mode
        eof: true

## Dependencies

    path = require 'path'
    misc = require '../../misc'
