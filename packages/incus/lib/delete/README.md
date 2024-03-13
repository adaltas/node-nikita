
# `nikita.incus.delete`

Delete a Linux Container using incus.

## Example

```js
const {$status} = await nikita.incus.delete({
  container: "myubuntu"
})
console.info(`Container was deleted: ${$status}`)
```
