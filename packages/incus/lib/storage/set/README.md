# `nikita.incus.storage.set`

Set properties to a storage pool.

## Example

```js
const { storages } = await nikita.incus.storage.set({
  properties: {
    size: "22GB",
    "zfs.clone_copy": false,
  },
});
```
