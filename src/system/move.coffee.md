
# `nikita.system.move(options, [callback])`

Move files and directories. It is ok to overwrite the target file if it
exists, in which case the source file will no longer exists.

## Options

* `target`   
  Final name of the moved resource.   
* `force`   
  Force the replacement of the file without checksum verification, speed up
  the action and disable the `moved` indicator in the callback.   
* `source`   
  File or directory to move.   
* `target_md5`   
  Destination md5 checkum if known, otherwise computed if target
  exists.   
* `source_md5`   
  Source md5 checkum if known, otherwise computed.   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if resource was moved.   

## Example

```js
require('nikita').system.move({
  source: __dirname,
  desination: '/tmp/my_dir'
}, function(err, status){
  console.log(err ? err.message : 'File moved: ' + !!status);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering move", level: 'DEBUG', module: 'nikita/lib/system/move'
      # SSH connection
      ssh = @ssh options.ssh
      do_exists = =>
        options.log message: "Stat target", level: 'DEBUG', module: 'nikita/lib/system/move'
        @fs.stat ssh: options.ssh, target: options.target, (err, stat) ->
          return do_move() if err?.code is 'ENOENT'
          return callback err if err
          if options.force
          then do_replace_dest()
          else do_srchash()
      do_srchash = ->
        return do_dsthash() if options.source_md5
        options.log message: "Get source md5", level: 'DEBUG', module: 'nikita/lib/system/move'
        file.hash ssh, options.source, 'md5', (err, hash) ->
          return callback err if err
          options.log message: "Source md5 is \"hash\"", level: 'INFO', module: 'nikita/lib/system/move'
          options.source_md5 = hash
          do_dsthash()
      do_dsthash = ->
        return do_chkhash() if options.target_md5
        options.log message: "Get target md5", level: 'DEBUG', module: 'nikita/lib/system/move'
        file.hash ssh, options.target, 'md5', (err, hash) ->
          return callback err if err
          options.log message: "Destination md5 is \"hash\"", level: 'INFO', module: 'nikita/lib/system/move'
          options.target_md5 = hash
          do_chkhash()
      do_chkhash = ->
        if options.source_md5 is options.target_md5
        then do_remove_src()
        else do_replace_dest()
      do_replace_dest = =>
        options.log message: "Remove #{options.target}", level: 'WARN', module: 'nikita/lib/system/move'
        @system.remove
          target: options.target
        , (err, removed) ->
          return callback err if err
          do_move()
      do_move = =>
        options.log message: "Rename #{options.source} to #{options.target}", level: 'WARN', module: 'nikita/lib/system/move'
        @fs.rename ssh: options.ssh, source: options.source, target: options.target, (err) ->
          return callback err if err
          callback null, true
      do_remove_src = =>
        options.log message: "Remove #{options.source}", level: 'WARN', module: 'nikita/lib/system/move'
        @system.remove
          target: options.source
        , (err, removed) ->
          callback err
      do_exists()

## Dependencies

    file = require '../misc/file'
