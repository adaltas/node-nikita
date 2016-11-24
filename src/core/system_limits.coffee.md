
# `mecano.system_limits(options, [callback])`

Control system limits for a user.

## Options

*   `target` (string)   
    Where to write the file, default to "/etc/security/limits.d/#{options.user}.conf".   
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

## Implemented strategy

### nproc and nofile

there is two cases, depending on the specified value

1. int value

If an int value is specified, then mecano checks that the value is lesser than 
the kernel limit. Please be aware that it is necessary but not sufficient to 
guarantee that the user would be able to open session.

2. true value

If a true value is specified, then mecano set it to 75% of the kernel limit.
This value is neither optimal nor able to guarantee that the user would be
able to open session, but that is the best mecano can automatically do.

### Other values

Other values are not assessed by default.
They must be int typed, and no specific check is implemented.

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


## Callback parameters

*   `err`
    Error object if any.
*   `status`
    Value is "true" if limits configuration file has been modified.

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering system_limits", level: 'DEBUG', module: 'mecano/lib/system_limits'
      return callback Error "Incoherent options: both options system and user defined, #{JSON.stringify system: options.system, user: options.user}" if options.system and options.user
      options.user = '*' if options.system
      return callback Error "Missing required option 'user'" unless options.user
      options.target ?= "/etc/security/" + if options.user is '*' then "limits.conf" else "limits.d/#{options.user}.conf"
      write = []
      @
      # Calculate nofile from kernel limit
      .execute
        cmd: "cat /proc/sys/fs/file-max"
        shy: true
        if: options.nofile?
      , (err, status, stdout) ->
        # console.log err, status, stdout
        throw err if err
        return unless status
        kern_limit = parseInt stdout.trim()
        if options.nofile is true then options.nofile = Math.round kern_limit*0.75
        else if typeof options.nofile is 'number'
          throw Error "Invalid nofile options. Please set int value lesser than kernel limit: #{kern_limit}" if options.nofile >= kern_limit
        else if typeof options.nofile is 'object'
          for _, v of options.nofile
            throw Error "Invalid nofile options. Please set int value lesser than kernel limit: #{kern_limit}" if v >= kern_limit
      # Calculate nproc from kernel limit
      .execute
        cmd: "cat /proc/sys/kernel/pid_max"
        shy: true
        if: options.nproc?
      , (err, status, stdout) ->
        throw err if err
        return unless status
        kern_limit = parseInt stdout.trim()
        if options.nproc is true then options.nproc = Math.round kern_limit*0.75
        else if typeof options.nproc is 'number'
          throw Error "Invalid nproc options. Please set int value lesser than kernel limit: #{kern_limit}" if options.nproc >= kern_limit
        else if typeof options.nproc is 'object'
          for _, v of options.nproc
            throw Error "Invalid nproc options. Please set int value lesser than kernel limit: #{kern_limit}" if v >= kern_limit
      .call ->
        for opt in ['as', 'core', 'cpu', 'data', 'fsize', 'locks', 'maxlogins',
        'maxsyslogins', 'memlock', 'msgqueue', 'nice', 'nofile', 'nproc',
        'priority', 'rss', 'sigpending', 'stack', 'rtprio']
          if options[opt]?
            options[opt] = '-': options[opt] unless typeof options[opt] is 'object'
            for k in Object.keys options[opt]
              throw Error "Invalid option: #{JSON.stringify options[opt]}" unless k in ['soft', 'hard', '-']
              throw Error "Invalid option: #{options[opt][k]} not a number" unless (typeof options[opt][k] is 'number') or options[opt][k] is 'unlimited'
              write.push
                match: RegExp "^#{regexp.escape options.user} +#{regexp.escape k} +#{opt}.+$", 'm'
                replace: "#{options.user}    #{k}    #{opt}    #{options[opt][k]}"
                append: true
        return false
      .file
        target: options.target
        write: write
        eof: true
        uid: options.uid
        gid: options.gid
        if: -> write.length
      .then callback

## Dependencies

    {regexp} = require '../misc'
