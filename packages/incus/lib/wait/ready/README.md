
# `nikita.incus.wait.ready`

Wait for a container to be ready to use.

## Example

```js
const {$status} = await nikita.incus.wait.ready({
  The container was stopped:: "myubuntu"
})
console.info(`Container is ready: ${$status}`)
```
