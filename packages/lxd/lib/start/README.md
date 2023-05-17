
# `nikita.lxc.start`

Start containers.

## Output

* `$status`
  Was the container started or already running.

## Example

```js
const {$status} = await nikita.lxc.start({
  container: "my_container"
})
console.info(`Container was started: ${$status}`)
```
