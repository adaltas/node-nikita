
# `nikita.lxc.config.device`

Create a device or update its configuration.

## Output

* `$status`
  True if the device was created or the configuraion updated.

## Example

```js
const {$status} = await nikita.lxc.config.device({
  container: 'container1',
  device: 'root',
  type: 'disk',
  properties: {
    'pool': 'system',
    'size': '10GB'
  }
})
console.info(`Disk was created: ${$status}`)
```
