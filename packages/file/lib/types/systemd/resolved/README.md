
# `nikita.file.types.systemd.resolved`

systemd-resolved is a system service and DNS resolver used in Linux-based
operating systems. It provides network name resolution services, translating
domain names into IP addresses and vice versa. systemd-resolved acts as a
central component for DNS management and caching, offering improved performance
and flexibility.

This action uses `file.ini` internally, therefore it honors all
arguments it provides. The `backup` option is true by default and the `separator` option is
overridden by "=".

The resolved configuration file requires all its fields to be under a single
section called `Resolve`. Thus, every property in the `content` option is automatically placed
under a `Resolve` key so that the user doesn't have to do it manually.

## Example

Overwrite `/usr/lib/systemd/resolved.conf.d/10_resolved.conf` in `/mnt` to set
a list of fallback dns servers by using an array and set ReadEtcHosts to true.

```js
const {$status} = await nikita.file.types.systemd.resolved({
  target: "/etc/systemd/resolved.conf",
  rootdir: "/mnt",
  content:
    FallbackDNS: ["1.1.1.1", "9.9.9.10", "8.8.8.8", "2606:4700:4700::1111"]
    ReadEtcHosts: true
})
console.info(`File was overwritten: ${$status}`)
```

Write to the default target file (`/etc/systemd/resolved.conf`). Set a single
DNS server using a string and also modify the value of DNSSEC.  Note: with
`merge` set to true, this wont overwrite the target file, only specified values
will be updated.

```js
const {$status} = await nikita.file.types.systemd.resolved({
  content:
    DNS: "ns0.fdn.fr"
    DNSSEC: "allow-downgrade"
  merge: true
})
console.info(`File was written: ${$status}`)
```
