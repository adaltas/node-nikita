
# `nikita.system.link`

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
}, function(err, {status}){
  console.info(err ? err.message : 'Link created: ' + status);
});
```

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering link", level: 'DEBUG', module: 'nikita/lib/system/link'
      count = 0
      sym_exists = (options, callback) =>
        @fs.base.readlink target: options.target, (err, {target}) ->
          return callback null, false if err
          return callback null, true if target is options.source
          @fs.base.unlink target: options.target, (err) ->
            return callback err if err
            callback null, false
      sym_create = (options, callback) =>
        @fs.base.symlink source: options.source, target: options.target, (err) ->
          return callback err if err
          count++
          callback()
      exec_exists = (options, callback) =>
        @fs.base.exists target: options.target, (err, {exists}) ->
          return callback null, false unless exists
          @fs.base.readFile target: options.target, encoding: 'utf8', (err, {data}) ->
            return callback err if err
            exec_cmd = /exec (.*) \$@/.exec(data)[1]
            callback null, exec_cmd and exec_cmd is options.source
      exec_create = (options, callback) =>
        content = """
        #!/bin/bash
        exec #{options.source} $@
        """
        @fs.base.writeFile target: options.target, content: content, (err) ->
          return callback err if err
          @fs.base.chmod target: options.target, mode: options.mode, (err) ->
            return callback err if err
            count++
            callback()
      return callback Error "Missing source, got #{JSON.stringify(options.source)}" unless options.source
      return callback Error "Missing target, got #{JSON.stringify(options.target)}" unless options.target
      options.mode ?= 0o0755
      do_mkdir = =>
        @system.mkdir
          target: path.dirname options.target
        , (err, created) ->
          # It is possible to have collision if to symlink
          # have the same parent directory
          return callback err if err and err.code isnt 'EEXIST'
          do_dispatch()
      do_dispatch = =>
        if options.exec
          exec_exists options, (err, exists) ->
            return do_end() if exists
            exec_create options, do_end
        else
          sym_exists options, (err, exists) ->
            return do_end() if exists
            sym_create options, do_end
      do_end = ->
        callback null, status: !!count, count: count
      do_mkdir()

## Dependencies

    path = require 'path'
