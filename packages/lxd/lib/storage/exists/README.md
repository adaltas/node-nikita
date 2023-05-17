
# `nikita.lxc.storage.exists`

Check if a storage exists.

## Output

* `exists`
  True if the object was deleted

## Example

```js
const {exists} = await nikita.lxc.storage.exists({
  name: 'system'
})
console.info(`Storage exists: ${exists}`)
```
