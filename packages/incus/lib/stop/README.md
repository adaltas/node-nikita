
# `nikita.incus.stop`

Stop a running Linux Container.

## Example

```js
const { $status } = await nikita.incus.stop({
  container: "my-container",
  wait: true,
  wait_retry: 5,
});
console.info("The container was stopped:", $status);
```
