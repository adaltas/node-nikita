# `nikita.incus.config.device.exists`

Check if the device exists in a container.

## Output

- `$status`  
  True if the device exist, false otherwise.
- `device`  
  Device information object.

## Add a network interface

```js
const { exists, device } = await nikita.incus.config.device.exists({
  name: "my-container",
  device: "eth0",
});
console.info(
  exists ? `device exists, type is ${device.type}` : "device missing",
);
```
