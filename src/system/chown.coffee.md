
# `nikita.system.chown(options, [callback])`

Change the ownership of a file or a directory.

## Options

* `gid`   
  Group name or id who owns the target file.   
* `stat` (Stat instance, optional)   
  Pass the Stat object relative to the target file or directory, to be
  used as an optimization, discovered otherwise.   
* `target`   
  Where the file or directory is copied.   
* `uid`   
  User name or id who owns the target file.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
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

    module.exports = (options) ->
      options.log message: "Entering chown", level: 'DEBUG', module: 'nikita/lib/chown'
      options.target = options.argument if options.argument?
      # Validate parameters
      throw Error "Missing target option" unless options.target?
      throw Error "Missing one of uid or gid option" unless options.uid? or options.gid?
      # Convert user and group names to uid and gid if necessary
      @call (_, callback) ->
        uid_gid options, callback
      # Use option 'stat' short-circuit or discover
      @call unless: options.stat, (_, callback) ->
        options.log message: "Stat #{options.target}", level: 'DEBUG', module: 'nikita/lib/chown'
        fs.stat options.ssh, options.target, (err, stat) ->
          return callback Error "Target Does Not Exist: #{JSON.stringify options.target}" if err?.code is 'ENOENT'
          return callback err if err
          options.stat = stat
          callback()
      # Detect changes
      @call (_, callback) ->
        # Detect changes
        if (not options.uid or options.stat.uid is options.uid) and (not options.gid or options.stat.gid is options.gid)
          options.log message: "Matching ownerships on '#{options.target}'", level: 'INFO', module: 'nikita/lib/chown'
          return callback()
        callback null, true
      @call if: (-> @status -1), (_, callback) ->
        # Apply changes
        options.uid ?= options.stat.uid
        options.gid ?= options.stat.gid
        fs.chown options.ssh, options.target, options.uid, options.gid, (err) ->
          options.log message: "change uid from #{options.stat.uid} to #{options.uid}", level: 'WARN', module: 'nikita/lib/chown' if options.stat.uid is not options.uid
          options.log message: "change gid from #{options.stat.gid} to #{options.gid}", level: 'WARN', module: 'nikita/lib/chown' if options.stat.gid is not options.gid
          callback err

## Dependencies

    fs = require 'ssh2-fs'
    uid_gid = require '../misc/uid_gid'
