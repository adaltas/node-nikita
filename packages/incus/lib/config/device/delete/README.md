# `nikita.incus.config.device.delete`

Delete a device from a container

## Output

- `$status`
  True if the device was removed False otherwise.

## Example

```js
const { $status } = await nikita.incus.config.device.delete({
  name: "my-container",
  device: "root",
});
console.info(`Device removed: ${$status}`);
```
