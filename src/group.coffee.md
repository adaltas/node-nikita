
# `group([goptions], options, callback)`

Create or modify a Unix group.

## Options

*   `name`   
    Login name of the group.   
*   `system`   
    Create a system account, such user are not created with ahome by default,
    set the "home" option if we it to be created.   
*   `gid`   
    Group name or number of the user´s initial login group.   
*   `ssh`   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `log`   
    Function called with a log related messages.   

## Callback Parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Number of created or modified groups.   

## Example

```js
require('mecano').group({
  name: "myself"
  system: true
  gid: 490
}, function(err, modified){
  console.log(err ? err.message : 'Group was created/modified: ' + modified);
});
```

The result of the above action can be viewed with the command
`cat /etc/group | grep myself` producing an output similar to
"myself:x:490:".

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments, parallel: true
      result = child()
      finish = (err, gmodified) ->
        callback err, gmodified if callback
        result.end err, gmodified
      misc.options options, (err, options) ->
        return finish err if err
        gmodified = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          return next new Error "Option 'name' is required" unless options.name
          options.system ?= false
          options.gid ?= null
          modified = false
          info = null
          do_info = ->
            options.log? "Get group information for #{options.name}"
            options.ssh?.cache_group = null # Clear cache if any 
            misc.ssh.group options.ssh, (err, groups) ->
              return next err if err
              options.log? "Got #{JSON.stringify groups[options.name]}"
              info = groups[options.name]
              if info then do_compare() else do_create()
          do_create = ->
            cmd = 'groupadd'
            cmd += " -r" if options.system
            cmd += " -g #{options.gid}" if options.gid
            cmd += " #{options.name}"
            execute
              ssh: options.ssh
              cmd: cmd
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
              code_skipped: 9
            , (err, created) ->
              return next err if err
              if created
              then modified = true
              else options.log? "Group defined elsewhere than '/etc/group', exit code is 9"
              next()
          do_compare = ->
            for k in ['gid']
              modified = true if options[k]? and info[k] isnt options[k]
            options.log? "Did group information changed: #{modified}"
            if modified then do_modify() else next()
          do_modify = ->
            cmd = 'groupmod'
            cmd += " -g #{options.gid}" if options.gid
            cmd += " #{options.name}"
            execute
              ssh: options.ssh
              cmd: cmd
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err) ->
              return next err
          do_info()
        .on 'both', (err) ->
          finish err, gmodified
      result

## Dependencies

    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'








