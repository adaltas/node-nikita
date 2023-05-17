
# `nikita.lxc.query`

Send a raw query to LXD.

## Example

```js
const { data } = await nikita.lxc.query({
  path: "/1.0/instances/c1",
});
console.info(`Container c1 info: ${data}`);
```

## TODO

The `lxc query` command comes with a few flag which we shall support:

```
Flags:
      --raw       Print the raw response
```
