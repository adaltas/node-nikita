
# `nikita.lxc.delete`

Delete a Linux Container using lxc.

## Example

```js
const {$status} = await nikita.lxc.delete({
  container: "myubuntu"
})
console.info(`Container was deleted: ${$status}`)
```
