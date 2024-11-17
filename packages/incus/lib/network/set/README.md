
# `nikita.incus.set`

Set Incus network configuration properties.

## Example

```js
const { $status } = await nikita.incus.network.set({
  name: "my-network",
  properites: {
    "ipv4.nat": "true"
  }
});
console.info(`Network configuration changed:`, $status);
```

## Incus output example

Incus output is available in the `network` returned property.

```json
{
		"config": {
			"ipv4.address": "10.79.130.1/24",
			"ipv4.nat": "true",
			"ipv6.address": "none"
		},
		"description": "",
		"name": "incusbr0",
		"type": "bridge",
		"used_by": [
			"/1.0/profiles/default",
			"/1.0/profiles/default?project=nikita",
			"/1.0/instances/valkey",
			"/1.0/instances/arch?project=nikita"
		],
		"managed": true,
		"status": "Created",
		"locations": [
			"none"
		],
		"project": "default"
	} 
```
