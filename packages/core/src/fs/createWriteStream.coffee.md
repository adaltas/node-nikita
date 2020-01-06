
# `nikita.fs.createWriteStream(options, callback)`

Options include

* `content` (string|buffer)   
  Content to write.
* `flags` (string)   
  File flags, see [open(2)](http://man7.org/linux/man-pages/man2/open.2.html).
* `mode` (string|int)   
  Permission mode.
* `target` (string)   
  Final destination path.
* `target_tmp` (string)   
  Temporary file for upload before moving to final destination path.

## Example

```javascript
require('nikita')
.fs.createWriteStream({
  target: '/path/to/file'
  stream: function(ws){
    ws.write('some content');
    ws.end();
  }
}, function(err){
  console.info(err ? err.message : 'File written');
})
```

## Source Code

    module.exports = status: false, log: false, handler: ({metadata, options}) ->
      @log message: "Entering fs.createWriteStream", level: 'DEBUG', module: 'nikita/lib/fs/createWriteStream'
      ssh = @ssh options.ssh
      # Normalize options
      options.target = metadata.argument if metadata.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      throw Error "Required Option: the \"stream\" option is mandatory" unless options.stream
      options.flags ?= 'w' # Note, Node.js docs version 8 & 9 mention "flag" and not "flags"
      options.target_tmp ?= "/tmp/nikita_#{string.hash options.target}" if options.sudo or options.flags[0] is 'a'
      options.mode ?= 0o644 # Node.js default to 0o666
      @system.execute
        if: options.flags[0] is 'a'
        cmd: """
        [ ! -f '#{options.target}' ] && exit
        cp '#{options.target}' '#{options.target_tmp}'
        """
      , (err, {status}) ->
        return unless status # Condition with flag "a" didnt pass
        @log unless err
        then message: "Append prepared by placing original file in temporary path", level: 'INFO', module: 'nikita/lib/fs/createWriteStream'
        else message: "Failed to place original file in temporary path", level: 'ERROR', module: 'nikita/lib/fs/createWriteStream'
      @call (_, callback) ->
        @log message: 'Writting file', level: 'DEBUG', module: 'nikita/lib/fs/createWriteStream'
        fs.createWriteStream ssh, options.target_tmp or options.target, flags: options.flags, mode: options.mode, (err, ws) ->
          return callback err if err
          options.stream ws
          # Quick fix ws sending both the error and close events on error
          error = false
          ws.on 'error', (err) ->
            error = true
            if ssh and err.code is 2
              err = Error "ENOENT: no such file or directory, open '#{options.target_tmp or options.target}'"
              err.errno = -2
              err.code = 'ENOENT'
              err.syscall = 'open'
              err.path = options.target_tmp or options.target
            callback err
          ws.on 'end', ->
            ws.destroy()
          ws.on 'close', ->
            callback() unless error
      @system.execute
        if: options.target_tmp
        cmd: """
        mv '#{options.target_tmp}' '#{options.target}'
        """
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot

## Dependencies

    fs = require 'ssh2-fs'
    string = require '../misc/string'
