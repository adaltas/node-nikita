
# `nikita.system.group`

Create or modify a Unix group.

## Options

* `cache` (boolean)   
  Retrieve groups information from cache.
* `name`   
  Login name of the group.   
* `system`   
  Create a system account, such user are not created with ahome by default,
  set the "home" option if we it to be created.   
* `gid`   
  Group name or number of the user´s initial login group.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if group was created or modified.   

## Example

```js
require('nikita')
.system.group({
  name: 'myself'
  system: true
  gid: 490
}, function(err, status){
  console.log(err ? err.message : 'Group was created/modified: ' + status);
});
```

The result of the above action can be viewed with the command
`cat /etc/group | grep myself` producing an output similar to
"myself:x:490:".

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering group", level: 'DEBUG', module: 'nikita/lib/system/group'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      options.name = options.argument if options.argument?
      throw Error "Option 'name' is required" unless options.name
      options.system ?= false
      options.gid ?= null
      options.gid = parseInt options.gid, 10 if typeof options.gid is 'string'
      throw Error 'Invalid gid option' if options.gid? and isNaN options.gid
      info = null
      @system.group.read
        cache: options.cache
      , (err, {status, groups}) ->
        info = groups[options.name]
        @log if info
        then message: "Got group information for #{JSON.stringify options.name}", level: 'DEBUG', module: 'nikita/lib/system/group'
        else message: "Group #{JSON.stringify options.name} not present", level: 'DEBUG', module: 'nikita/lib/system/group'
      # Create group
      @call unless: (-> info), ->
        @system.execute
          cmd: (
            cmd = 'groupadd'
            cmd += " -r" if options.system
            cmd += " -g #{options.gid}" if options.gid?
            cmd += " #{options.name}"
          )
          code_skipped: 9
        , (err, {status}) ->
          throw err if err
          @log message: "Group defined elsewhere than '/etc/group', exit code is 9", level: 'WARN', module: 'nikita/lib/system/group' unless status
      # Modify group
      @call if: (-> info), ->
        changed = []
        for k in ['gid']
          changed.push 'gid' if options[k]? and "#{info[k]}" isnt "#{options[k]}"
        @log if changed.length
        then message: "Group information modified", level: 'WARN', module: 'nikita/lib/system/group'
        else message: "Group information unchanged", level: 'DEBUG', module: 'nikita/lib/system/group'
        return unless changed.length
        @system.execute
          if: changed.length
          cmd: (
            cmd = 'groupmod'
            cmd += " -g #{options.gid}" if options.gid
            cmd += " #{options.name}"
          )
      # Reset Cache
      @call
        if: -> @status()
      , ->
        delete  @store['nikita:etc_group']
