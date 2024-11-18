
# `nikita.incus.config.device`

Create a device or update its configuration.

## Output

* `$status`
  True if the device was created or the configuraion updated.

## Example

```js
const {$status} = await nikita.incus.config.device({
  name: 'my-container',
  device: 'root',
  type: 'disk',
  properties: {
    'pool': 'system',
    'size': '10GB'
  }
})
console.info(`Disk was created: ${$status}`)
```
