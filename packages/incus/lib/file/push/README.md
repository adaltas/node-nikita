
# `nikita.incus.file.push`

Push files into containers.

## Example

```js
const {$status} = await nikita.incus.file.push({
  name: 'my-container',
  source: `#{scratch}/a_file`,
  target: '/root/a_file'
})
console.info(`File was pushed: ${$status}`)
```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from incus_target
