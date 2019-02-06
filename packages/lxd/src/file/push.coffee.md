
# `nikita.lxd.file.push`

Push files into containers.

## Options

* `name` (string, required)   
  The name of the container.
* `create_dirs` (boolean, optional, false)
  Create any directories necessary.
* `gid` (integer, optional)   
  Set the file's gid on push.
  overwrite the `source` option.
* `lxd_target` (string, required)   
  File destination in the form of "[<remote>:]<container>/<path>",
  overwrite the `target` option.
* `mode` (integer|string, optional)   
  Set the file's perms on push.
* `source` (string, required)   
  File to push in the form of "<path>".
* `target` (string, required)   
  File destination in the form of "<path>".
* `uid` (integer, optional)   
  Set the file's uid on push.

## Example

```
require('nikita')
.lxd.file.push({
  name: "myubuntu"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was deleted')
});

```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering lxd.file.push", level: 'DEBUG', module: '@nikitajs/lxd/lib/push'
      throw Error "Invalid Option: name is required" unless options.name # note, name could be obtained from lxd_target
      throw Error "Invalid Option: source is required" unless options.source
      throw Error "Invalid Option: target is required" unless options.target or options.lxd_target
      options.algo ?= 'md5'
      options.lxd_target ?= "#{path.join options.name, options.target}"
      # Execution
      cmd_push = [
        'lxc', 'file', 'push'
        options.source
        options.lxd_target
        '--create-dirs' if options.create_dirs
        '--gid' if options.gid? and typeof options.gid is 'number'
        '--uid' if options.uid? and typeof options.uid is 'number'
        "--mode #{options.mode}" if options.mode
      ].join ' '
      @system.execute
        cmd: """
        # Ensure source is a file
        [ -f "#{options.source}" ] || exit 2
        command -v openssl >/dev/null || exit 3
        sourceDgst=`openssl dgst -#{options.algo} #{options.source} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'`
        # Get target hash
        targetDgst=`cat <<EOF | lxc exec #{options.name} -- bash
        # Ensure openssl is available
        command -v openssl >/dev/null || exit 4
        openssl dgst -#{options.algo} #{options.target} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
        EOF`
        [ "$sourceDgst" == "$targetDgst" ] && exit 42
        #{cmd_push}
        """
        code_skipped: 42
        trap: true
        trim: true
      , (err, {status, stdout}) ->
        throw Error "Invalid Option: source is not a file, got #{JSON.stringify options.source}" if err?.code is 2
        throw Error "Invalid Requirement: openssl not installed on host" if err?.code is 3
        throw Error "Invalid Requirement: openssl not installed on container" if err?.code is 4
      @lxd.exec
        if: typeof options.gid is 'string'
        name: options.name
        cmd: "chgrp #{options.gid} #{options.target}"
      @lxd.exec
        if: typeof options.uid is 'string'
        name: options.name
        cmd: "chown #{options.uid} #{options.target}"

## Dependencies

    path = require 'path'
