
# `nikita.system.user.remove`

Create or modify a Unix user.

## Options

* `arch_chroot` (boolean|string)   
  Run this command inside a root directory with the arc-chroot command or any
  provided string, require the "rootdir" option if activated.
* `rootdir` (string)   
  Path to the mount point corresponding to the root directory, required if
  the "arch_chroot" option is activated.
* `name`   
  Name of the user to removed.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  Value is "true" if user was created or modified.

## Example

```coffee
require('nikita')
.system.user.remove({
  name: 'a_user'
}, function(err, {status}){
  console.log(err ? err.message : 'User removed: ' + status);
})
```

The result of the above action can be viewed with the command
`cat /etc/passwd | grep myself` producing an output similar to
"a\_user:x:490:490:A System User:/home/a\_user:/bin/bash". You can also check
you are a member of the "wheel" group (gid of "10") with the command
`id a\_user` producing an output similar to 
"uid=490(hive) gid=10(wheel) groups=10(wheel)".

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering remove", level: 'DEBUG', module: 'nikita/lib/system/user/remove'
      options.name = options.argument if options.argument?
      throw Error "Option 'name' is required" unless options.name
      @system.execute
        cmd: "userdel #{options.name}"
        code_skipped: 6
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
        sudo: options.sudo
