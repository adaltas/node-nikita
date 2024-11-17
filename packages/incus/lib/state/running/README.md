# `nikita.incus.state.running`

Check if container is running.

## Output

- `$status`
  Was the container started or already running.

## Example

```js
const { running } = await nikita.incus.state.running({
  container: "my_container",
});
console.info(`Container is running: ${running}`);
```
