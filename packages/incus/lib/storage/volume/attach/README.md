
# `nikita.incus.storage.volume.attach`

Attach a storage volume in the selected pool to an instance of LXD.

## Output parameters

* `$status`
  True if the volume was attached.

## Example

```js
const {$status} = await @incus.storage.volume.attach({
  pool = 'default',
  name = 'test',
  container = 'c1',
  device = 'test'
})
console.info(`The volume was deleted: ${$status}`)
```
