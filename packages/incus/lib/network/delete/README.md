
# `nikita.incus.network.delete`

Delete an existing incus network.

## Output

* `$status`   
  True if the network was deleted.

## Example

```js
const {$status} = await nikita.incus.network.delete({
  network: 'network0'
})
console.info(`Network was deleted: ${$status}`)
```
