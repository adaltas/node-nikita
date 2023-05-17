
# `nikita.lxc.running`

Check if container is running.

## Output

* `$status`
  Was the container started or already running.

## Example

```js
const {$status} = await nikita.lxc.running({
  container: "my_container"
})
console.info(`Container is running: ${$status}`)
```
