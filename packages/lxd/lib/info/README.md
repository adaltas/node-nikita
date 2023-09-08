
# `nikita.lxc.info`

Obtain container information.

## Output

* `container`
  Information object returned by LXD.

## Short usage example

```js
const {container} = await nikita.lxc.info("my_container")
console.info("Container information:", JSON.stringify(container, null, 2))
```
