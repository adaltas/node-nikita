# `nikita.incus.delete`

Delete a Linux Container using incus.

## Example

```js
const { $status } = await nikita.incus.delete({
  name: "my-container",
});
console.info("Container was deleted:", $status);
```
