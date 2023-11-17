
# `nikita.system.running`

Check if a process is running.

## Check if the pid is running

The example check if a pid match a running process.

```js
const {$status} = await nikita.system.running({
  pid: 1034,
})
console.info(`Is PID running: ${$status}`)
```

## Check if the pid stored in a file is running

The example read a file and check if the pid stored inside is currently running.
This pattern is used by YUM and APT to create lock files. The target file will
be removed if it stores a value not matching a running pid.

```js
const {$status} = await nikita.system.running({
  target: '/var/run/yum.pid'
})
console.info(`Is PID running: ${$status}`)
```
