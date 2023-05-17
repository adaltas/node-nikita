
# `nikita.lxc.config.device.delete`

Delete a device from a container

## Output

* `$status`
  True if the device was removed False otherwise.

## Example

```js
const {$status} = await nikita.lxc.config.device.delete({
  container: 'container1',
  device: 'root'
})
console.info(`Device was removed: ${$status}`)
```
