
# `system_limits(options, callback)`

Control system limits for a user.

## Ulimit

Linux allows to limit the resources allocated to users or user groups via
"/etc/security/limits.conf" and "/etc/security/limits.d/*.conf" file loaded by
WFP (Plugable Authentication Module) at each logon.
The user can then adapt the resources available to its needs via "ulimit".

It is possible to define, for a number of resources (number of open files, file size,
number of instantiated process, CPU time, etc.), a "soft" limit which can be
increased by user, via "ulimit" until a maximum "hard" limit.
The system does not exceed the value of the soft limit. If the user wants to push
this limit, it will set a new soft limit with ulimit.
The soft limit is always lower or equal to the hard limit.
In general, the limits applied to a user override those applied to a group.

## Ulimit commands

Pass the "S" option to "ulimit" will impact the effective limit ("soft" limit)
and the "H" the "hard" limit (maximum value that can be defined by the user).

                       |   soft     |   hard     |  unit   |
-----------------------|------------|------------|---------|
| core file size       | ulimit -Sc | ulimit -Hc | blocks  |
| data seg size        | ulimit -Sd | ulimit -Hd | kbytes  |
| scheduling priority  | ulimit -Se | ulimit -He |         |
| file size            | ulimit -Sf | ulimit -Hf | blocks  |
| max locked memory    | ulimit -Sl | ulimit -Hl | kbytes  |
| pending signals      | ulimit -Si | ulimit -Hi |         |
| max memory size      | ulimit -Sm | ulimit -Hm | kbytes  |
| open files           | ulimit -Sn | ulimit -Hn |         |
| pipe size            | ulimit -Sp | ulimit -Hp | bytes   |
| POSIX message queues | ulimit -Sq | ulimit -Hq | bytes   |
| real-time priority   | ulimit -Sr | ulimit -Hr |         |
| stack size           | ulimit -Ss | ulimit -Hs | kbytes  |
| cpu time             | ulimit -St | ulimit -Ht | seconds |
| max user processes   | ulimit -Su | ulimit -Hu |         |
| virtual memory       | ulimit -Sv | ulimit -Hv | kbytes  |
| file locks           | ulimit -Sx | ulimit -Hx |         |

Pass the option in flag-mode to get, and follows it with a value to set

## Kernel Limits

User limits cannot exceed kernel limits, so you need to configure kernel limits
before user limits.

### Processes

```bash
sysctl kernel.pid_max         # print kernel.pid_max = VALUE
cat /proc/sys/kernel/pid_max  # print VALUE
```

1. Temporary change

```bash
echo 4194303 > /proc/sys/kernel/pid_max
```

2. Permanent change

Edit /etc/sysctl.conf:
```bash
kernel.pid_max = 4194303
```

### Open Files

```bash
sysctl fs.file-max         # print fs.file-max = VALUE
cat /proc/sys/fs/file-max  # print VALUE
```

1. Temporary change

```bash
echo 1631017 > /proc/sys/fs/file-max
```

2. Permanent change

Edit /etc/sysctl.conf:
```bash
fs.file-max = 1631017
```

## Options

*   `destination` (string)
    Where to write the file, default to "/etc/security/limits.d/#{options.user}.conf".
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

Count the number of sub-process for a process:

```bash
ls /proc/14986/task | wc
ps -L p $pid --no-headers | wc -l
```

Count the number of sub-process for a user:
The option "-L" show threads, possibly with LWP and NLWP columns.

```bash
ps -L -u $user --no-headers | wc -l
```

Maximum number of open files: `ulimit -Hn`
Maximum number of process: `ulimit -u`

## Source Code

    module.exports = (options, callback) ->
      return callback new Error "Missing required option 'user'" unless options.user
      options.nofile if options.nofile is true
      options.nproc = 65536 if options.nproc is true
      throw Error 'Invalid option "nofile"' if options.nofile? and typeof options.nofile not in ['number', 'boolean']
      throw Error 'Invalid option "nproc"' if options.nproc? and typeof options.nproc not in ['number', 'boolean']
      options.destination ?= "/etc/security/limits.d/#{options.user}.conf"
      write = []
      @
      .execute
        cmd: "ulimit -Hn"
        shy: true
        if: options.nofile is true
      , (err, status, stdout) ->
        # console.log err, status, stdout
        return callback err if err
        return unless status
        options.nofile = stdout.trim()
      .call ->
        return unless options.nofile?
        write.push
          match: ///^#{options.user}.+nofile.+$///m
          replace: "#{options.user}    -    nofile   #{options.nofile}"
          append: true
        false
      .call ->
        return unless options.nproc?
        write.push
          match: ///^#{options.user}.+nproc.+$///m
          replace: "#{options.user}    -    nproc   #{options.nproc}"
          append: true
        false
      .write
        destination: options.destination
        write: write
        eof: true
        uid: options.uid
        gid: options.gid
        if: -> write.length
      .then callback

## Dependencies

    execute = require './execute'
