
# `nikita.incus.query`

Send a raw query to LXD.

## Example

```js
const { data } = await nikita.incus.query({
  path: "/1.0/instances/c1",
});
console.info(`Container c1 info: ${data}`);
```

## TODO

The `incus query` command comes with a few flag which we shall support:

```
Flags:
      --raw       Print the raw response
```
