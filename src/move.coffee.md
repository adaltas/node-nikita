
# `move(options, [goptions], callback)`

Move files and directories. It is ok to overwrite the destination file if it
exists, in which case the source file will no longer exists.

## Options

*   `destination`   
    Final name of the moved resource.   
*   `force`   
    Force the replacement of the file without checksum verification, speed up
    the action and disable the `moved` indicator in the callback.   
*   `source`   
    File or directory to move.   
*   `destination_md5`   
    Destination md5 checkum if known, otherwise computed if destination
    exists.   
*   `source_md5`   
    Source md5 checkum if known, otherwise computed.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `moved`   
    Number of moved resources.   

## Example

```js
require('mecano').move({
  source: __dirname,
  desination: '/tmp/my_dir'
}, function(err, moved){
  console.log(err ? err.message : "File moved: " + !!moved);
});
```

    module.exports = (goptions, options, callback) ->
      wrap arguments, (options, next) ->
        do_exists = ->
          fs.stat options.ssh, options.destination, (err, stat) ->
            return do_move() if err?.code is 'ENOENT'
            return next err if err
            if options.force
            then do_replace_dest()
            else do_srchash()
        do_srchash = ->
          return do_dsthash() if options.source_md5
          misc.file.hash options.ssh, options.source, 'md5', (err, hash) ->
            return next err if err
            options.source_md5 = hash
            do_dsthash()
        do_dsthash = ->
          return do_chkhash() if options.destination_md5
          misc.file.hash options.ssh, options.destination, 'md5', (err, hash) ->
            return next err if err
            options.destination_md5 = hash
            do_chkhash()
        do_chkhash = ->
          if options.source_md5 is options.destination_md5
          then do_remove_src()
          else do_replace_dest()
        do_replace_dest = ->
          options.log? "Remove #{options.destination}"
          remove
            ssh: options.ssh
            destination: options.destination
          , (err, removed) ->
            return next err if err
            do_move()
        do_move = ->
          options.log? "Rename #{options.source} to #{options.destination}"
          fs.rename options.ssh, options.source, options.destination, (err) ->
            return next err if err
            next null, true
        do_remove_src = ->
          options.log? "Remove #{options.source}"
          remove
            ssh: options.ssh
            destination: options.source
          , (err, removed) ->
            next err
        do_exists()

## Dependencies

    fs = require 'ssh2-fs'
    remove = require './remove'
    misc = require './misc'
    wrap = require './misc/wrap'






