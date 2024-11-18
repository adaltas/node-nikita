
# `nikita.incus.config.set`

Set container or server configuration keys.

## Set a configuration key

```js
const {$status} = await nikita.incus.config.set({
  name: "my-container",
  properties: {
    'boot.autostart.priority': 100
  }
})
console.info(`Property was set: ${$status}`)
```
