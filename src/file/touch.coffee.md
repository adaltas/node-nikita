
# `nikita.file.touch(options, [callback])`

Create a empty file if it does not yet exists.

## Implementation details

Status will only be true if the file was created.

## Options

* `atime` (Date|int)  
  Access time, default to now.   
* `gid`   
  File group name or group id.   
* `mode`   
  File mode (permission and sticky bits), default to `0o0666`, in the form of
  `{mode: 0o0744}` or `{mode: "0744"}`.   
* `mtime` (Date|int)  
  Modification time, default to now.   
* `target`   
  File path where to write content to.   
* `uid`   
  File user name or user id.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file was created or modified.   

## Example

```js
require('nikita').file.touch({
  ssh: ssh,
  target: '/tmp/a_file'
}, function(err, touched){
  console.log(err ? err.message : 'File touched: ' + !!touched);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering file.touch", level: 'DEBUG', module: 'nikita/lib/file/touch'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      options.target = options.argument if options.argument?
      throw Error "Missing target: #{options.target}" unless options.target

Test if file exists.

      @call (_, callback) ->
        options.log message: "Check if target exists \"#{options.target}\"", level: 'DEBUG', module: 'nikita/lib/file/touch'
        fs.exists ssh, options.target, (err, exists) ->
          options.log message: "Destination does not exists", level: 'INFO', module: 'nikita/lib/file/touch' if not err and not exists
          return callback err, !exists

If true, update access and modification time, status wont be affected

      @call
        unless: -> @status()
        shy: true
      , (_, callback) ->
        options.atime ?= Date.now()
        options.mtime ?= Date.now()
        fs.futimes ssh, options.target, options.atime, options.mtime, (err) ->
          options.log message: "Access and modification times updated", level: 'DEBUG', module: 'nikita/lib/file/touch' unless err
          callback err

If not, write a new empty file.

      @file
        content: ''
        target: options.target
        if: -> @status()
        mode: options.mode
        uid: options.uid
        gid: options.gid

## Dependencies

    fs = require 'ssh2-fs'
