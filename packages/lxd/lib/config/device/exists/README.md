
# `nikita.lxc.config.device.exists`

Check if the device exists in a container.

## Output

* `$status`
  True if the device exist, false otherwise.

## Add a network interface

```js
const {$status, config} = await nikita.lxc.config.device.exists({
  container: "my_container",
  device: 'eth0'
})
console.info($status ? `device exists, type is ${config.type}` : 'device missing')
```
