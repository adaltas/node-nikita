
# `nikita.incus.list`

List the instances managed by LXD.

## Example

```js
const { list } = await nikita.incus.list({
  filter: "containers",
});
console.info(`LXD containers: ${list}`);
```
