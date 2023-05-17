
# `nikita.lxc.network.delete`

Delete an existing lxd network.

## Output

* `$status`   
  True if the network was deleted.

## Example

```js
const {$status} = await nikita.lxc.network.delete({
  network: 'network0'
})
console.info(`Network was deleted: ${$status}`)
```
