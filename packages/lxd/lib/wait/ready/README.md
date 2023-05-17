
# `nikita.lxc.wait.ready`

Wait for a container to be ready to use.

## Example

```js
const {$status} = await nikita.lxc.wait.ready({
  container: "myubuntu"
})
console.info(`Container is ready: ${$status}`)
```
