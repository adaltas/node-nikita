
# `nikita.system.chown(options, [callback])`

Change the ownership of a file or a directory.

## Options

*   `gid`   
    Group name or id who owns the target file.   
*   `stat` (Stat instance, optional)   
    Pass the Stat object relative to the target file or directory, to be
    used as an optimization.   
*   `target`   
    Where the file or directory is copied.   
*   `uid`   
    User name or id who owns the target file.   

## Callback Parameters

*   `err`   
    Error object if any.   
*   `status`   
    Value is "true" if file ownership was created or modified.   

## Example

```js
require('nikita').system.chown({
  target: '~/my/project',
  uid: 'my_user'
  gid: 'my_group'
}, function(err, modified){
  console.log(err ? err.message : 'File was modified: ' + modified);
});
```

## Note

To list all files owner by a user or a uid, run:

```bash
find /var/tmp -user `whoami`
find /var/tmp -uid 1000
find / -uid $old_uid -print | xargs chown $new_uid:$new_gid
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering chown", level: 'DEBUG', module: 'nikita/lib/chown'
      # Validate parameters
      return callback Error "Missing target option" unless options.target?
      return callback Error "Missing one of uid or gid option" unless options.uid? or options.gid?
      do_uid_gid = ->
        uid_gid options, (err) ->
          return callback err if err
          do_stat()
      do_stat = ->
        # Option 'stat' short-circuit
        return do_chown options.stat if options.stat
        options.log message: "Stat #{options.target}", level: 'DEBUG', module: 'nikita/lib/chown'
        fs.stat options.ssh, options.target, (err, stat) ->
          return callback err if err
          do_chown stat
      do_chown = (stat) ->
        # Detect changes
        if stat.uid is options.uid and stat.gid is options.gid
          options.log message: "Matching ownerships on '#{options.target}'", level: 'INFO', module: 'nikita/lib/chown'
          return callback()
        # Apply changes
        fs.chown options.ssh, options.target, options.uid, options.gid, (err) ->
          options.log message: "change uid from #{stat.uid} to #{options.uid}", level: 'WARN', module: 'nikita/lib/chown'
          options.log message: "change gid from #{stat.gid} to #{options.gid}", level: 'WARN', module: 'nikita/lib/chown'
          callback err, true
      do_uid_gid()

## Dependencies

    fs = require 'ssh2-fs'
    uid_gid = require '../misc/uid_gid'
