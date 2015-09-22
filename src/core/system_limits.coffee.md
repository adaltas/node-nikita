
# `system_limits(options, callback)`

Control system limits for a user.

## Ulimit

Linux allows to limit the resources allocated to users or user groups via
"/etc/security/limits.conf" and "/etc/security/limits.d/*.conf" files loaded by
WFP (Plugable Authentication Module) at each logon. The user can then adapt the
resources available to its needs via "ulimit".

It is possible to define, for a number of resources (number of open files, file size,
number of instantiated process, CPU time, etc.), a "soft" limit which can be
increased by user, via "ulimit" until a maximum "hard" limit.
The system does not exceed the value of the soft limit. If the user wants to push
this limit, it will set a new soft limit with ulimit.
The soft limit is always lower or equal to the hard limit.
In general, the limits applied to a user override those applied to a group.

## Ulimit commands

The "S" option to "ulimit" impact the effective limit ("soft" limit) and the "H"
impact the "hard" limit (maximum value that can be defined by the user).

| resource             |   soft     |   hard     |  unit   |
|----------------------|------------|------------|---------|
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

Pass the option in flag-mode to get, and follows it with a value to set.

## Retrieve current information

Number of sub-process for a process:

```bash
pid=14986
ls /proc/$pid/task | wc
ps -L p $pid --no-headers | wc -l
```

Number of sub-process for a user:
The option "-L" show threads, possibly with LWP and NLWP columns.

```bash
user=`whoami`
ps -L -u $user --no-headers | wc -l
```

## Kernel Limits

User limits cannot exceed kernel limits, so you need to configure kernel limits
before user limits.

### Processes

```bash
sysctl kernel.pid_max         # print kernel.pid_max = VALUE
cat /proc/sys/kernel/pid_max  # print VALUE
```

_Temporary change_: `echo 4194303 > /proc/sys/kernel/pid_max`

_Permanent change_: `vi /etc/sysctl.conf # kernel.pid_max = 4194303`

### Open Files

```bash
sysctl fs.file-max         # print fs.file-max = VALUE
cat /proc/sys/fs/file-max  # print VALUE
```

_Temporary change_: `echo 1631017 > /proc/sys/fs/file-max`

_Permanent change_ : `vi /etc/sysctl.conf # fs.file-max = 1631017`


## Options

*   `destination` (string)   
    Where to write the file, default to "/etc/security/limits.d/#{options.user}.conf".   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `as` (int)   
    Address space limit (KB)   
*   `core` (int)   
    Limits the core file size (KB)   
*   `cpu`  (int)   
    CPU time limit (in seconds).   
    When the process reaches the soft limit, it receives a SIGXCPU every second.   
    When it reaches the hard limit, it receives SIGKILL.   
*   `data` (int)   
    Max data size (KB)   
*   `fsize` (int)   
    Maximum filesize (KB)   
*   `locks` (int)   
    Max number of file locks the user can hold.   
*   `maxlogins` (int)   
    Max number of logins for this user.   
*   `maxsyslogins` (int)   
    Max number of logins on the system.   
*   `memlock` (int)   
    Max locked-in-memory address space (KB)   
*   `msgqueue` (int)   
    Max memory used by POSIX message queues (bytes)   
*   `nice` (int: [-20, 19])   
    Max nice priority allowed to raise to values   
*   `nofile` (int)   
    Max number of open file descriptors   
*   `nproc` (int)   
    Max number of processes   
*   `priority` (int)   
    Priority to run user process with   
*   `rss` (int)   
    Max resident set size (KB)   
*   `sigpending` (int)   
    Max number of pending signals.   
*   `stack` (int)   
    Max stack size (KB)   
*   `rtprio` (int)   
    Max realtime priority.   

## Callback parameters

*   `err`
    Error object if any.
*   `modifed`
    True if limits configuration file has been modified.

## Source Code

    module.exports = (options, callback) ->
      return callback Error "Missing required option 'user'" unless options.user
      # Parameters where value can be guessed
      for opt in ['nofile', 'nproc']
        return callback Error "Invalid option '#{opt}'" if options[opt]? and typeof options[opt] not in ['boolean','number']
      # Parameters where value cannot be guessed
      for opt in ['as', 'core', 'cpu', 'data', 'fsize', 'locks', 'maxlogins',
      'maxsyslogins', 'memlock', 'msgqueue', 'nice', 'priority', 'rss',
      'sigpending', 'stack', 'rtprio']
        return callback Error "Invalid option '#{opt}'" if options[opt]? and typeof options[opt] isnt 'number'
      options.destination ?= "/etc/security/limits.d/#{options.user}.conf"
      write = []
      @
      # Calculate nofile from kernel limit
      .execute
        cmd: "cat /proc/sys/fs/file-max"
        shy: true
        if: options.nofile is true
      , (err, status, stdout) ->
        # console.log err, status, stdout
        return callback err if err
        return unless status
        options.nofile = stdout.trim()
      # Calculate nproc from kernel limit
      .execute
        cmd: "cat /proc/sys/kernel/pid_max"
        shy: true
        if: options.nproc is true
      , (err, status, stdout) ->
        return callback err if err
        return unless status
        options.nproc = stdout.trim()
      .call ->
        for opt in ['as', 'core', 'cpu', 'data', 'fsize', 'locks', 'maxlogins',
        'maxsyslogins', 'memlock', 'msgqueue', 'nice', 'nofile', 'nproc',
        'priority', 'rss', 'sigpending', 'stack', 'rtprio']
          if options[opt]?
            write.push
              match: RegExp "^#{options.user}.+#{opt}.+$", 'm'
              replace: "#{options.user}    -    #{opt}   #{options[opt]}"
              append: true
        return false
      .write
        destination: options.destination
        write: write
        eof: true
        uid: options.uid
        gid: options.gid
        if: -> write.length
      .then callback

## Dependencies

No dependency
