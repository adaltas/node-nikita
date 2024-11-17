# `nikita.incus.operation.show`

Show details on an Incus background operation, [learn more](https://linuxcontainers.org/incus/docs/main/reference/manpages/incus/operation/show/).

## Example

```js
const { operation } = await nikita.incus.operation.show({
  name: "344a79e4-d88a-45bf-9c39-c72c26f6ab8a",
});
console.info(`Operation information:`, operation);
```
