# `nikita.incus.info`

Retrieve detailed container information.

## Output

- `container`
  Information object returned by LXD.

## Short usage example

```js
const { data } = await nikita.incus.info("my_container");
console.info("Container information:", JSON.stringify(data, null, 2));
```
