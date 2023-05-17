
# `nikita.lxc.list`

List the instances managed by LXD.

## Example

```js
const { list } = await nikita.lxc.list({
  filter: "containers",
});
console.info(`LXD containers: ${list}`);
```
