
# `nikita.fs.stat`

Retrieve file information.

## Output parameters

The parameters include a subset as the one of the Node.js native 
[`fs.Stats`](https://nodejs.org/api/fs.html#fs_class_fs_stats) object.

* `mode` (integer)   
  A bit-field describing the file type and mode.
* `uid` (integer)   
  The numeric user identifier of the user that owns the file (POSIX).
* `gid` (integer)   
  The numeric group identifier of the group that owns the file (POSIX).
* `size` (integer)   
  The size of the file in bytes.
* `atime` (integer)   
  The timestamp indicating the last time this file was accessed expressed in milliseconds since the POSIX Epoch.
* `mtime` (integer)   
  The timestamp indicating the last time this file was modified expressed in milliseconds since the POSIX Epoch.

## File information

The `mode` parameter indicates the file type. For conveniency, the
`@nikitajs/engine/lib/utils/stats` module provide functions to check each
possible file types.

## Examples

Check if target is a file:

```js
stats = require('@nikitajs/core/lib/misc/stats')
require('nikita')
.file.touch("#{scratch}/a_file")
.fs.stat("#{scratch}/a_file", function(err, {stats}){
  assert(stats.isFile(stats.mode) === true)
})
```

Check if target is a directory:

```js
stats = require('@nikitajs/engine/lib/utils/stats')
require('nikita')
.system.mkdir("#{scratch}/a_file")
.fs.stat("#{scratch}/a_file", function(err, {stats}){
  assert(stats.isDirectory(stats.mode) === true)
})
```

## Note

The `stat` command return an empty stdout in some circounstances like uploading
a large file with `file.download`, thus the activation of `retry` and `sleep`
confguration properties.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## schema

    schema =
      type: 'object'
      properties:
        'dereference':
          type: 'boolean'
          description: """
          Follow links, similar to `lstat`, default is "true", just like in the
          native Node.js `fs.stat` function, use `nikita.fs.lstat` to retrive
          link information.
          """
        'target':
          oneOf: [{type: 'string'}, 'instanceof': 'Buffer']
          description: """
          Location of the file to analyse
          """
      required: ['target']

## Handler

    handler = ({config, metadata}) ->
      @log message: "Entering fs.stat", level: 'DEBUG', module: 'nikita/lib/fs/stat'
      # Normalize configuration
      config.dereference ?= true
      dereference = if config.dereference then '-L' else ''
      try
        {stdout} = await @execute
          cmd: """
          [ ! -e #{config.target} ] && exit 3
          if [ -d /private ]; then
            stat #{dereference} -f '%Xp|%u|%g|%z|%a|%m' #{config.target} # MacOS
          else
            stat #{dereference} -c '%f|%u|%g|%s|%X|%Y' #{config.target} # Linux
          fi
          """
          # sudo: config.sudo
          # bash: config.bash
          # arch_chroot: config.arch_chroot
          trim: true
        [rawmodehex, uid, gid, size, atime, mtime] = stdout.split '|'
        stats:
          mode: parseInt '0xa1ed' + rawmodehex, 16
          uid: parseInt uid, 10
          gid: parseInt gid, 10
          size: parseInt size, 10
          atime: parseInt atime, 10
          mtime: parseInt mtime, 10
      catch err
        if err.exit_code is 3
          throw error 'NIKITA_FS_STAT_TARGET_ENOENT', [
            'failed to stat the target, no file exists for target,'
            "got #{JSON.stringify config.target}"
          ],
            exit_code: err.exit_code
            errno: -2
            syscall: 'rmdir'
            path: config.target
        else
          throw err

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        raw_output: true
      schema: schema

## Dependencies

    constants = require('fs').constants
    error = require '../../utils/error'

## Stat implementation

On Linux, the format argument is '-c'. The following codes are used:

- `%f`  The raw mode in hexadecimal.
- `%u`  The user ID of owner.
- `%g`  The group ID of owner.
- `%s`  The block size of file.
- `%X`  The time of last access, seconds since Epoch.
- `%y`  The time of last modification, human-readable.

On MacOS, the format argument is '-f'. The following codes are used:

- `%Xp` File type and permissions in hexadecimal.
- `%u`  The user ID of owner.
- `%g`  The group ID of owner.
- `%z`  The size of file in bytes.
- `%a`  The time file was last accessed.
- `%m`  The time file was last modified.
