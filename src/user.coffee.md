
`user([goptions], options, callback)`
--------------------------------------

Create or modify a Unix user.

    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'

`options`           Command options include:

*   `name`          Login name of the user.   
*   `home`          Value for the user´s login directory, default to the login name appended to "BASE_DIR".   
*   `shell`         Path to the user shell, set to "/sbin/nologin" if "false,
                    "/bin/bash" if true or default to the system shell value in
                    "/etc/default/useradd", by default "/bin/bash".   
*   `system`        Create a system account, such user are not created with a home by default, set the "home" option if we it to be created.   
*   `uid`           Numerical value of the user´s ID, must not exist.   
*   `gid`           Group name or number of the user´s initial login group.   
*   `comment`       Short description of the login.   
*   `password`      User password
*   `expiredate`    
*   `inactive`      
*   `groups`        
*   `skel`          
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
*   `log`           Function called with a log related messages.   

`callback`          Received parameters are:

*   `err`           Error object if any.
*   `modified`      Number of created or modified users.

Example:

```coffee
mecano.user
  name: "myself"
  system: true
  uid: 490
  gid: 10
  comment: 'This is myself'
, (err, modified) -> ...
```

The result of the above action can be viewed with the command
`cat /etc/passwd | grep myself` producing an output similar to
"myself:x:490:10:Hive:/home/myself:/bin/bash". You can also check you are a
member of the "wheel" group (gid of "10") with the command `id hive` producing
an output similar to "uid=490(hive) gid=10(wheel) groups=10(wheel)".

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
          # options.comment ?= ""
          # options.home ?= "/home/#{options.name}"
          # options.shell ?= "/sbin/nologin"
          options.shell = "/sbin/nologin" if options.shell is false
          options.shell = "/bin/bash" if options.shell is true
          options.system ?= false
          options.gid ?= null
          options.groups = options.groups.split ',' if typeof options.groups is 'string'
          return next new Error "Invalid option 'shell': #{JSON.strinfigy options.shell}" if options.shell? typeof options.shell isnt 'string'
          modified = false
          user_info = groups_info = null
          do_info = ->
            options.log? "Get user information for #{options.name}"
            options.ssh?.passwd = null # Clear cache if any 
            misc.ssh.passwd options.ssh, (err, users) ->
              return next err if err
              options.log? "Got #{JSON.stringify users[options.name]}"
              user_info = users[options.name]
              # Create user if it does not exist
              return do_create() unless user_info
              # Compare user attributes unless we need to compare groups membership
              return do_compare() unless options.groups
              # Renew group cache
              options.ssh?.cache_group = null # Clear cache if any
              misc.ssh.group options.ssh, (err, groups) ->
                return next err if err
                groups_info = groups
                do_compare()
              # if info then do_compare() else do_create()
          do_create = ->
            cmd = 'useradd'
            cmd += " -r" if options.system
            cmd += " -M" unless options.home
            cmd += " -d #{options.home}" if options.home
            cmd += " -s #{options.shell}" if options.shell
            cmd += " -c #{misc.string.escapeshellarg options.comment}" if options.comment
            cmd += " -u #{options.uid}" if options.uid
            cmd += " -g #{options.gid}" if options.gid
            cmd += " -e #{options.expiredate}" if options.expiredate
            cmd += " -f #{options.inactive}" if options.inactive
            cmd += " -G #{options.groups.join ','}" if options.groups
            cmd += " -k #{options.skel}" if options.skel
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
                modified = true
                do_password()
              else
                options.log? "User defined elsewhere than '/etc/passwd', exit code is 9"
                next()
          do_compare = ->
            for k in ['uid', 'home', 'shell', 'comment', 'gid']
              modified = true if options[k]? and user_info[k] isnt options[k]
            if options.groups then for group in options.groups
              return next err "Group does not exist: #{group}" unless groups_info[group]
              modified = true if groups_info[group].user_list.indexOf(options.name) is -1
            options.log? "Did user information changed: #{modified}"
            if modified then do_modify() else do_password()
          do_modify = ->
            cmd = 'usermod'
            cmd += " -d #{options.home}" if options.home
            cmd += " -s #{options.shell}" if options.shell
            cmd += " -c #{misc.string.escapeshellarg options.comment}" if options.comment?
            cmd += " -g #{options.gid}" if options.gid
            cmd += " -G #{options.groups.join ','}" if options.groups
            cmd += " -u #{options.uid}" if options.uid
            cmd += " #{options.name}"
            execute
              ssh: options.ssh
              cmd: cmd
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, _, __, stderr) ->
              return next new Error "User #{options.name} is logged in" if err?.code is 8
              return next err if err
              do_password()
          do_password = ->
            return next() unless options.password
            # TODO, detect changes in password
            execute
              ssh: options.ssh
              cmd: "echo #{user.password} | passwd --stdin #{user.username}"
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err) ->
              next err
          do_info()
        .on 'both', (err) ->
          finish err, gmodified
      result