# `nikita.incus.state.running`

Check if container is running.

## Output

- `running`  
  Was the container started or already running.

## Example

```js
const { running } = await nikita.incus.state.running({
  name: "my-container",
});
console.info(`Container is running: ${running}`);
```
