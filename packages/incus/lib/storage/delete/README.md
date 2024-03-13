
# `nikita.incus.storage.delete`

Delete an existing incus storage.

## Output

* `$status`
  True if the object was deleted

## Example

```js
const {$status} = await nikita.incus.storage.delete({
  name: 'system'
})
console.info(`Storage was deleted: ${$status}`)
```
