
# `nikita.incus.config.device.show`

Show full device configuration for containers or profiles.

## Output parameters

* `$status` (boolean)
  True if the device was created or the configuraion updated.
* `properties` (object)   
  Device configuration.

## Example

```js
const {properties} = await nikita.incus.config.device.show({
  container: 'container1',
  device: 'vpn'
})
console.info(properties)
// { connect: "udp:127.0.0.1:1194",
// listen: "udp:51.68.116.44:1194",
// type: proxy } }
```
