# `nikita.incus.storage.volume.get`

Get a storage volume in the selected pool.

## Output parameters

- `$status`
  True if the volume was obtained.
- `volume`
  The volume information returned by the API call.

## Example

```js
const { volume } = await nikita.incus.storage.volume.get({
  pool: "default",
  name: "test",
});
console.info("Volume informations", volume);
```
