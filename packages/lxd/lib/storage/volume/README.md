
# `nikita.lxc.storage.volume`

Create a new storage volume in the selected pool.

## Output parameters

* `$status`
  True if the volume was created.

## Example

```js
const {$status} = await @lxc.storage({
  pool = 'default',
  name = 'test',
})
console.info(`The pool creation was correctly made: ${$status}`)
```
