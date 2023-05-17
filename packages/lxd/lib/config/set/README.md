
# `nikita.lxc.config.set`

Set container or server configuration keys.

## Set a configuration key

```js
const {$status} = await nikita.lxc.config.set({
  name: "my_container",
  properties: {
    'boot.autostart.priority': 100
  }
})
console.info(`Property was set: ${$status}`)
```
