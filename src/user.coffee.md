
# `user(options, [goptions], callback)`

Create or modify a Unix user.

## Options

*   `name`   
    Login name of the user.   
*   `home`   
    Value for the user´s login directory, default to the login name appended to "BASE_DIR".   
*   `shell`   
    Path to the user shell, set to "/sbin/nologin" if "false, "/bin/bash" if
    true or default to the system shell value in "/etc/default/useradd", by
    default "/bin/bash".   
*   `system`   
    Create a system account, such user are not created with a home by default,
    set the "home" option if we it to be created.   
*   `uid`   
    Numerical value of the user´s ID, must not exist.   
*   `gid`   
    Group name or number of the user´s initial login group.   
*   `groups`   
    List of supplementary groups which the user is also a member of.   
*   `comment`   
    Short description of the login.   
*   `password`   
    The unencrypted password.  
*   `expiredate`  
    The date on which the user account is disabled.     
*   `inactive`   
    The number of days after a password has expired before the account will be
    disabled.   
*   `skel`   
    The skeleton directory, which contains files and directories to be copied in
    the user´s home directory, when the home directory is created by useradd.   
*   `log`   
    Function called with a log related messages.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Number of created or modified users.   

## Example

```coffee
require('mecano').user({
  name: 'a_user',
  system: true,
  uid: 490,
  gid: 10,
  comment: 'A System User'
}, function(err, created){
  console.log(err ? err.message : 'User created: ' + !!created);
})
```

The result of the above action can be viewed with the command
`cat /etc/passwd | grep myself` producing an output similar to
"a\_user:x:490:490:A System User:/home/a\_user:/bin/bash". You can also check
you are a member of the "wheel" group (gid of "10") with the command
`id a\_user` producing an output similar to 
"uid=490(hive) gid=10(wheel) groups=10(wheel)".

## Source Code

    module.exports = (options, callback) ->
      wrap arguments, (options, callback) ->
        return callback new Error "Option 'name' is required" unless options.name
        options.shell = "/sbin/nologin" if options.shell is false
        options.shell = "/bin/bash" if options.shell is true
        options.system ?= false
        options.gid ?= null
        options.groups = options.groups.split ',' if typeof options.groups is 'string'
        return callback new Error "Invalid option 'shell': #{JSON.strinfigy options.shell}" if options.shell? typeof options.shell isnt 'string'
        modified = false
        user_info = groups_info = null
        do_info = ->
          options.log? "Get user information for #{options.name}"
          options.ssh?.passwd = null # Clear cache if any 
          misc.ssh.passwd options.ssh, (err, users) ->
            return callback err if err
            options.log? "Got #{JSON.stringify users[options.name]}"
            user_info = users[options.name]
            # Create user if it does not exist
            return do_create() unless user_info
            # Compare user attributes unless we need to compare groups membership
            return do_compare() unless options.groups
            # Renew group cache
            options.ssh?.cache_group = null # Clear cache if any
            misc.ssh.group options.ssh, (err, groups) ->
              return callback err if err
              groups_info = groups
              do_compare()
        do_create = ->
          cmd = 'useradd'
          cmd += " -r" if options.system
          cmd += " -M" unless options.home
          cmd += " -d #{options.home}" if options.home
          cmd += " -s #{options.shell}" if options.shell
          cmd += " -c #{string.escapeshellarg options.comment}" if options.comment
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
            return callback err if err
            if created
              modified = true
              do_password()
            else
              options.log? "User defined elsewhere than '/etc/passwd', exit code is 9"
              callback null, modified
        do_compare = ->
          for k in ['uid', 'home', 'shell', 'comment', 'gid']
            modified = true if options[k]? and user_info[k] isnt options[k]
          if options.groups then for group in options.groups
            return callback err "Group does not exist: #{group}" unless groups_info[group]
            modified = true if groups_info[group].user_list.indexOf(options.name) is -1
          options.log? "Did user information changed: #{modified}"
          if modified then do_modify() else do_password()
        do_modify = ->
          cmd = 'usermod'
          cmd += " -d #{options.home}" if options.home
          cmd += " -s #{options.shell}" if options.shell
          cmd += " -c #{string.escapeshellarg options.comment}" if options.comment?
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
            return callback new Error "User #{options.name} is logged in" if err?.code is 8
            return callback err if err
            do_password()
        do_password = ->
          return callback null, modified unless options.password
          # TODO, detect changes in password
          execute
            ssh: options.ssh
            cmd: "echo #{user.password} | passwd --stdin #{user.username}"
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err) ->
            callback err, modified
        do_info()

## Dependencies

    each = require 'each'
    misc = require './misc'
    string = require './misc/string'
    wrap = require './misc/wrap'
    execute = require './execute'







