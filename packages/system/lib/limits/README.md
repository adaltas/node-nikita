
# `nikita.system.limits`

Control system limits for a user.

## Implementation strategy

### `nproc` and `nofile`

There are two cases, depending on the specified value:

1. Integer value   
  If an int value is specified, then nikita checks that the value is lesser than the kernel limit. Please be aware that it is necessary but not sufficient to guarantee that the user would be able to open session.
2. Boolean value
  If a true value is specified, then nikita set it to 75% of the kernel limit. This value is neither optimal nor able to guarantee that the user would be able to open session, but that is the best nikita can automatically do.

### Other values

Other values are not assessed by default. They must be integers.

## Ulimit

Linux allows to limit the resources allocated to users or user groups via "/etc/security/limits.conf" and "/etc/security/limits.d/*.conf" files loaded by WFP (Plugable Authentication Module) at each logon. The user can then adapt the resources available to its needs via "ulimit". Refer to the [limits.conf(5)](https://linux.die.net/man/5/limits.conf) Linux man page for further information.

It is possible to define, for a number of resources (number of open files, file size, number of instantiated process, CPU time, etc.), a "soft" limit which can be increased by user, via "ulimit" until a maximum "hard" limit. The system does not exceed the value of the soft limit. If the user wants to push this limit, it will set a new soft limit with ulimit. The soft limit is always lower or equal to the hard limit. In general, the limits applied to a user override those applied to a group.

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

Number of sub-process for a user, the option "-L" show threads, possibly with LWP and NLWP columns:

```bash
user=`whoami`
ps -L -u $user --no-headers | wc -l
```

## Kernel Limits

User limits cannot exceed kernel limits, so you need to configure kernel limits before user limits.

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

## Example

Setting the number of open file descriptors to .75 of the maximum value for  all the users:

```js
const {$status} = await nikita.system.limits({
  system: true,
  nofile: true
});
console.info(`Limits modified: ${$status}`);
```
