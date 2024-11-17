# `nikita.incus.operation.delete`

Delete an Incus background operation (will attempt to cancel), [learn more](https://linuxcontainers.org/incus/docs/main/reference/manpages/incus/operation/list/).

## Example

```js
const { $status } = await nikita.incus.operation.delete({
  name: "344a79e4-d88a-45bf-9c39-c72c26f6ab8a",
});
console.info(`Operation deleted:`, $status);
```
