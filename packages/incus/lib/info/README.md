# `nikita.incus.info`

Retrieve detailed container information.

## Output

- `container`
  Information object returned by LXD.

## Short usage example

```js
const { container } = await nikita.incus.info("my-container");
console.info("Container information:", container);
```
