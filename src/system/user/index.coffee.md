
# `nikita.system.user.add(options, [callback])`

Create or modify a Unix user.

If the user home is provided, its parent directory will be created with root 
ownerships and 0644 permissions unless it already exists.

## Options

* `arch_chroot` (boolean|string)   
  Run this command inside a root directory with the arc-chroot command or any
  provided string, require the "rootdir" option if activated.
* `rootdir` (string)   
  Path to the mount point corresponding to the root directory, required if
  the "arch_chroot" option is activated.
* `comment`   
  Short description of the login.
* `expiredate`   
  The date on which the user account is disabled.
* `gid`   
  Group name or number of the user´s initial login group.
* `groups`   
  List of supplementary groups which the user is also a member of.
* `home`   
  Value for the user´s login directory, default to the login name appended to "BASE_DIR".
* `inactive`   
  The number of days after a password has expired before the account will be
  disabled.
* `name`   
  Login name of the user.
* `no_home_ownership` (boolean)   
  Disable ownership on home directory which default to the "uid" and "gid"
  options, default is "false".
* `password`   
  The unencrypted password.
* `password_sync`   
  Synchronize password, default is "true".
* `shell`   
  Path to the user shell, set to "/sbin/nologin" if "false", "/bin/bash" if
  true or default to the system shell value in "/etc/default/useradd", by
  default "/bin/bash".
* `skel`   
  The skeleton directory, which contains files and directories to be copied in
  the user´s home directory, when the home directory is created by useradd.
* `system`   
  Create a system account, such user are not created with a home by default,
  set the "home" option if we it to be created.
* `uid`   
  Numerical value of the user´s ID, must not exist.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  Value is "true" if user was created or modified.

## Example

```coffee
require('nikita').user({
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

    module.exports = (options) ->
      options.log message: "Entering user", level: 'DEBUG', module: 'nikita/lib/system/user/add'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      options.name = options.argument if options.argument?
      throw Error "Option 'name' is required" unless options.name
      options.shell = "/sbin/nologin" if options.shell is false
      options.shell = "/bin/bash" if options.shell is true
      options.system ?= false
      options.gid ?= null
      options.password_sync ?= true
      options.groups = options.groups.split ',' if typeof options.groups is 'string'
      throw Error "Invalid option 'shell': #{JSON.strinfigy options.shell}" if options.shell? typeof options.shell isnt 'string'
      modified = false
      user_info = groups_info = null
      @call (_, callback) ->
        # Note, we shall be able to remove the call to "uid_gid"
        # because it itself call "uid_gid.passwd" and "uid_gid.group"
        # which are called below
        uid_gid ssh, options, callback
      @call (_, callback) ->
        options.log message: "Get user information for #{options.name}", level: 'DEBUG', module: 'nikita/lib/system/user/add'
        options.store.cache_passwd = undefined # Clear cache if any
        uid_gid.passwd ssh, options.store, (err, users) ->
          return callback err if err
          options.log message: "Got #{JSON.stringify users[options.name]}", level: 'INFO', module: 'nikita/lib/system/user/add'
          user_info = users[options.name]
          callback()
      @call
        # Get group information if
        # * user already exists
        # * we need to compare groups membership
        if: -> user_info and options.groups
      , (_, callback) ->
        options.store.cache_group = null # Clear cache if any
        uid_gid.group ssh, options.store, (err, groups) ->
          return callback err if err
          groups_info = groups
          callback()
      @call if: options.home, ->
        @system.mkdir
          unless_exists: path.dirname options.home
          target: path.dirname options.home
          uid: 0
          gid: 0
          mode: 0o0644 # Same as '/home'
      @call unless: (-> user_info), ->
        cmd = 'useradd'
        cmd += " -r" if options.system
        cmd += " -M" unless options.home
        cmd += " -m" if options.home
        cmd += " -d #{options.home}" if options.home
        cmd += " -s #{options.shell}" if options.shell
        cmd += " -c #{string.escapeshellarg options.comment}" if options.comment
        cmd += " -u #{options.uid}" if options.uid
        cmd += " -g #{options.gid}" if options.gid
        cmd += " -e #{options.expiredate}" if options.expiredate
        cmd += " -f #{options.inactive}" if options.inactive
        cmd += " -G #{options.groups.join ','}" if options.groups
        cmd += " -k #{options.skel}" if options.skel
        cmd += " #{options.name}\n"
        cmd += "chown #{options.name}. #{options.home}" if options.home
        @system.execute
          cmd: cmd
          code_skipped: 9
          arch_chroot: options.arch_chroot
          rootdir: options.rootdir
          sudo: options.sudo
        , (err, status, stdout) ->
          throw err if err
          options.log message: "User defined elsewhere than '/etc/passwd', exit code is 9", level: 'WARN', module: 'nikita/lib/system/user/add'
        # @system.chown
        #   if: options.home?
        #   if_exists: options.home
        #   unless: options.no_home_ownership
        #   target: options.home
        #   uid: options.uid
        #   gid: options.gid
      @call if: (-> user_info), ->
        changed = []
        for k in ['uid', 'home', 'shell', 'comment', 'gid']
          changed.push k if options[k]? and user_info[k] isnt options[k]
        if options.groups then for group in options.groups
          throw Error "Group does not exist: #{group}" unless groups_info[group]
          changed.push 'groups' if groups_info[group].user_list.indexOf(options.name) is -1
        options.log if changed.length
        then message: "User #{options.name} modified", level: 'WARN', module: 'nikita/lib/system/user/add'
        else message: "User #{options.name} not modified", level: 'DEBUG', module: 'nikita/lib/system/user/add'
        cmd = 'usermod'
        cmd += " -d #{options.home}" if options.home
        cmd += " -s #{options.shell}" if options.shell
        cmd += " -c #{string.escapeshellarg options.comment}" if options.comment?
        cmd += " -g #{options.gid}" if options.gid
        cmd += " -G #{options.groups.join ','}" if options.groups
        cmd += " -u #{options.uid}" if options.uid
        cmd += " #{options.name}"
        @system.execute
          cmd: cmd
          if: changed.length
          arch_chroot: options.arch_chroot
          rootdir: options.rootdir
          sudo: options.sudo
        , (err) ->
          throw Error "User #{options.name} is logged in" if err?.code is 8
        @system.chown
          if: options.home and (options.uid or options.gid)
          if_exists: options.home
          unless: options.no_home_ownership
          target: options.home
          uid: options.uid
          gid: options.gid
      @call ->
        # TODO, detect changes in password
        # echo #{options.password} | passwd --stdin #{options.name}
        @system.execute
          cmd: """
          hash=$(echo #{options.password} | openssl passwd -1 -stdin)
          usermod --pass="$hash" #{options.name}
          """
          if: options.password_sync and options.password
          arch_chroot: options.arch_chroot
          rootdir: options.rootdir
          sudo: options.sudo
        , (err, modified) ->
          throw err if err
          options.log message: "Password modified", level: 'WARN', module: 'nikita/lib/system/user/add' if modified

## Dependencies

    path = require 'path'
    fs = require 'ssh2-fs'
    misc = require '../../misc'
    string = require '../../misc/string'
    uid_gid = require '../../misc/uid_gid'
