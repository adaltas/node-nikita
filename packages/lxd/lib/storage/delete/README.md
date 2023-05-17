
# `nikita.lxc.storage.delete`

Delete an existing lxd storage.

## Output

* `$status`
  True if the object was deleted

## Example

```js
const {$status} = await nikita.lxc.storage.delete({
  name: 'system'
})
console.info(`Storage was deleted: ${$status}`)
```
