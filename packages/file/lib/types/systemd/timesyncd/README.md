
# `nikita.file.types.systemd.timesyncd`

timesyncd is a system service in Linux-based operating systems that is
responsible for time synchronization. It utilizes the Network Time Protocol
(NTP) to ensure accurate and consistent timekeeping across the system. timesyncd
regularly contacts designated NTP servers to obtain the current time and adjusts
the system clock accordingly. It also tracks the system's time drift,
compensating for any discrepancies that may occur over time. timesyncd is
designed to be lightweight and efficient, providing a reliable time
synchronization solution without the need for additional software or complex
configurations. 

This action uses `file.ini` internally, therefore it honors all
arguments it provides. The `backup` option is true by default and the `separator` option is
overridden by "=".

The timesyncd configuration file requires all its fields to be under a single
section called `Time`. Thus, every property in the `content` option is automatically placed
under a `Time` key so that the user doesn't have to do it manually.

## Example

Overwrite `/usr/lib/systemd/timesyncd.conf.d/10_timesyncd.conf` in `/mnt` to
set a list of NTP servers by using an array and a single fallback server by
using a string.

```js
const {$status} = await nikita.file.types.systemd.timesyncd({
  target: "/usr/lib/systemd/timesyncd.conf.d/10_timesyncd.conf",
  rootdir: "/mnt",
  content:
    NTP: ["ntp.domain.com", "ntp.domain2.com", "ntp.domain3.com"]
    FallbackNTP: "fallback.domain.com"
})
console.info(`File was overwritten: ${$status}`)
```

Write to the default target file (`/etc/systemd/timesyncd.conf`). Set a single
NTP server using a string and also modify the value of RootDistanceMaxSec.
Note: with `merge` set to true, this wont overwrite the target file, only
specified values will be updated.

```js
const {$status} = await nikita.file.types.systemd.timesyncd({
  content:
    NTP: "0.arch.pool.ntp.org"
    RootDistanceMaxSec: 5
  merge: true
})
console.info(`File was written: ${$status}`)
```
