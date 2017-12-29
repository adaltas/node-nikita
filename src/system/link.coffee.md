
# `nikita.system.link(options, [callback])`

Create a symbolic link and it's parent directories if they don't yet
exist.

Note, it is valid for the "source" file to not exist.

## Options

* `source`   
  Referenced file to be linked.   
* `target`   
  Symbolic link to be created.   
* `exec`   
  Create an executable file with an `exec` command.   
* `mode`   
  Default to `0o0755`.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if link was created or modified.   

## Example

```js
require('nikita').system.link({
  source: __dirname,
  target: '/tmp/a_link'
}, function(err, status){
  console.log(err ? err.message : 'Link created: ' + status);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering link", level: 'DEBUG', module: 'nikita/lib/system/link'
      # SSH connection
      ssh = @ssh options.ssh
      linked = 0
      sym_exists = (options, callback) ->
        fs.readlink ssh, options.target, (err, resolvedPath) ->
          return callback null, false if err
          return callback null, true if resolvedPath is options.source
          fs.unlink ssh, options.target, (err) ->
            return callback err if err
            callback null, false
      sym_create = (options, callback) ->
        fs.symlink ssh, options.source, options.target, (err) ->
          return callback err if err
          linked++
          callback()
      exec_exists = (options, callback) ->
        fs.exists ssh, options.target, (err, exists) ->
          return callback null, false unless exists
          fs.readFile ssh, options.target, 'utf8', (err, content) ->
            return callback err if err
            exec_cmd = /exec (.*) \$@/.exec(content)[1]
            callback null, exec_cmd and exec_cmd is options.source
      exec_create = (options, callback) ->
        content = """
        #!/bin/bash
        exec #{options.source} $@
        """
        fs.writeFile ssh, options.target, content, (err) ->
          return callback err if err
          fs.chmod ssh, options.target, options.mode, (err) ->
            return callback err if err
            linked++
            callback()
      return callback Error "Missing source, got #{JSON.stringify(options.source)}" unless options.source
      return callback Error "Missing target, got #{JSON.stringify(options.target)}" unless options.target
      options.mode ?= 0o0755
      do_mkdir = =>
        @system.mkdir
          ssh: ssh
          target: path.dirname options.target
        , (err, created) ->
          # It is possible to have collision if to symlink
          # have the same parent directory
          return callback err if err and err.code isnt 'EEXIST'
          do_dispatch()
      do_dispatch = ->
        if options.exec
          exec_exists options, (err, exists) ->
            return do_end() if exists
            exec_create options, do_end
        else
          sym_exists options, (err, exists) ->
            return do_end() if exists
            sym_create options, do_end
      do_end = ->
        callback null, linked
      do_mkdir()

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
