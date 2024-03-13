
# `nikita.incus.storage.volume.delete`

Delete a storage volume in the selected pool.

## Output parameters

* `$status`
  True if the volume was deleted.

## Example

```js
const {$status} = await @incus.storage.volume.delete({
  pool = 'default',
  name = 'test',
})
console.info(`The volume was deleted: ${$status}`)
```
