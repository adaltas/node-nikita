
# `nikita.incus.info`

Obtain container information.

## Output

* `container`
  Information object returned by LXD.

## Short usage example

```js
const {container} = await nikita.incus.info("my_container")
console.info("Container information:", JSON.stringify(container, null, 2))
```
