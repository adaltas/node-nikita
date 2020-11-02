
# `nikita.lxd.file.push`

Push files into containers.

## Example

```js
require('nikita')
.lxd.file.push({
  container: "my_container"
}, function(err, {status}) {
  console.info( err ? err.message : 'The container was deleted')
});
```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target

## Schema

    schema =
      type: 'object'
      properties:
        'algo':
          default: 'md5'
          $ref: 'module://@nikitajs/engine/src/actions/fs/hash#/properties/algo'
        'container':
          $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
        'content':
          type: 'string'
          description: """
          Content of the target file.
          """
        'create_dirs':
          type: 'boolean'
          default: false
          description: """
          Create any directories necessary.
          """
        'gid':
          type: ['integer', 'string']
          description: """
          Set the file's gid on push, overwrite the `source` option.
          """
        'lxd_target':
          type: 'string'
          description: """
          File destination in the form of "[<remote>:]<container>/<path>",
          overwrite the `target` option.
          """
        'mode':
          type: ['integer', 'string']
          description: """
            Set the file's perms on push.
          """
        'source':
          type: 'string'
          description: """
          File to push in the form of "<path>".
          """
        'target':
          type: 'string'
          description: """
          File destination in the form of "<path>".
          """
        'uid':
          type: ['integer', 'string']
          description: """
          Set the file's uid on push.
          """
      required: ['container', 'target']
      oneOf: [
        {required: ['content']}
        {required: ['source']}
      ]

## Handler

    handler = ({config, metadata: {tmpdir}}) ->
      # log message: "Entering lxd.file.push", level: 'DEBUG', module: '@nikitajs/lxd/lib/file/push'
      # Make source file with content
      if config.content?
        tmpfile = path.join tmpdir, "nikita.#{Date.now()}#{Math.round(Math.random()*1000)}"
        @fs.base.writeFile
          target: tmpfile
          content: config.content
        config.source = tmpfile
      # note, name could be obtained from lxd_target
      # throw Error "Invalid Option: target is required" if not config.target and not config.lxd_target
      config.lxd_target ?= "#{path.join config.container, config.target}"
      {status} = await @lxd.running
        container: config.container
      status_running = status
      if status
        try
          {status} = await @execute
            cmd: """
            # Ensure source is a file
            [ -f "#{config.source}" ] || exit 2
            command -v openssl >/dev/null || exit 3
            sourceDgst=`openssl dgst -#{config.algo} #{config.source} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'`
            # Get target hash
            targetDgst=`cat <<EOF | lxc exec #{config.container} -- bash
            # Ensure openssl is available
            command -v openssl >/dev/null || exit 4
            # Target does not exist
            [ ! -f "#{config.target}" ] && exit 0
            openssl dgst -#{config.algo} #{config.target} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
            EOF`
            [ "$sourceDgst" != "$targetDgst" ] || exit 42
            """
            code_skipped: 42
            trap: true
        catch err
          throw Error "Invalid Option: source is not a file, got #{JSON.stringify config.source}" if err.exit_code is 2
          throw Error "Invalid Requirement: openssl not installed on host" if err.exit_code is 3
          throw Error "Invalid Requirement: openssl not installed on container" if err.exit_code is 4
      if not status_running or status
        @execute
          cmd: """
          #{[
            'lxc', 'file', 'push'
            config.source
            config.lxd_target
            '--create-dirs' if config.create_dirs
            '--gid' if config.gid? and typeof config.gid is 'number'
            '--uid' if config.uid? and typeof config.uid is 'number'
            "--mode #{config.mode}" if config.mode
          ].join ' '}
          """
          trap: true
          trim: true
      if typeof config.gid is 'string'
        @lxd.exec
          container: config.container
          cmd: "chgrp #{config.gid} #{config.target}"
      if typeof config.uid is 'string'
        @lxd.exec
          container: config.container
          cmd: "chown #{config.uid} #{config.target}"

## Export

    module.exports =
      handler: handler
      metadata:
        tmpdir: true
      schema: schema

## Dependencies

    path = require 'path'
