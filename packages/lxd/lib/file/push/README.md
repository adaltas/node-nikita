
# `nikita.lxc.file.push`

Push files into containers.

## Example

```js
const {$status} = await nikita.lxc.file.push({
  container: 'my_container',
  source: `#{scratch}/a_file`,
  target: '/root/a_file'
})
console.info(`File was pushed: ${$status}`)
```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target
