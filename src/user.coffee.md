
# `user(options, callback)`

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
*   `no_home_ownership` (boolean)   
    Disable ownership on home directory which default to the "uid" and "gid"
    options, default is "false".   

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
        options.log? "Mecano `user`: Get user information for #{options.name} [DEBUG]"
        options.ssh?.passwd = null # Clear cache if any 
        misc.ssh.passwd options.ssh, (err, users) ->
          return callback err if err
          options.log? "Mecano `user`: got #{JSON.stringify users[options.name]} [INFO]"
          user_info = users[options.name]
          # Create user if it does not exist
          return do_create() unless user_info
          # Compare user attributes unless we need to compare groups membership
          return do_update() unless options.groups
          # Renew group cache
          options.ssh?.cache_group = null # Clear cache if any
          misc.ssh.group options.ssh, (err, groups) ->
            return callback err if err
            groups_info = groups
            do_update()
      do_create = =>
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
        @child()
        .execute
          cmd: cmd
          code_skipped: 9
        .chown
          destination: options.home
          uid: options.uid
          gid: options.gid
          if_exists: options.home
          not_if: options.no_home_ownership
        .then (err, created) ->
          return callback err if err
          if created
            modified = true
            do_password()
          else
            options.log? "Mecano `user`: user defined elsewhere than '/etc/passwd', exit code is 9 [WARN]"
            callback null, modified
      do_update = =>
        changed = false
        for k in ['uid', 'home', 'shell', 'comment', 'gid']
          changed = true if options[k]? and user_info[k] isnt options[k]
        if options.groups then for group in options.groups
          return callback err "Group does not exist: #{group}" unless groups_info[group]
          changed = true if groups_info[group].user_list.indexOf(options.name) is -1
        options.log? "Mecano `user`: user #{options.name} not modified [DEBUG]" unless changed
        options.log? "Mecano `user`: user #{options.name} modified [WARN]" if changed
        cmd = 'usermod'
        cmd += " -d #{options.home}" if options.home
        cmd += " -s #{options.shell}" if options.shell
        cmd += " -c #{string.escapeshellarg options.comment}" if options.comment?
        cmd += " -g #{options.gid}" if options.gid
        cmd += " -G #{options.groups.join ','}" if options.groups
        cmd += " -u #{options.uid}" if options.uid
        cmd += " #{options.name}"
        @child()
        .execute
          cmd: cmd
          if: changed
        .chown
          destination: options.home
          uid: options.uid
          gid: options.gid
          if: options.home
          if_exists: options.home
          not_if: options.no_home_ownership
        .then (err, changed, __, stderr) ->
          return callback new Error "User #{options.name} is logged in" if err?.code is 8
          return callback err if err
          modified = true if changed
          do_password()
      do_password = =>
        return do_end() unless options.password
        # TODO, detect changes in password
        @execute
          cmd: "echo #{user.password} | passwd --stdin #{user.username}"
        , (err, modified) ->
          return callback err if err
          # modified = true if modified
          do_end()
      do_end = ->
        return callback null, modified
      do_info()

## Dependencies

    each = require 'each'
    misc = require './misc'
    string = require './misc/string'







