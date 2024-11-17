
# `nikita.incus.operation.list`

List background Incus operations, [learn more](https://linuxcontainers.org/incus/docs/main/reference/manpages/incus/operation/list/).

## Example

```js
const {operations} = await nikita.incus.operation.list()
console.info(`Current operations:`, operations)
```
