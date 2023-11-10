
# `nikita.docker.rm`

Remove one or more containers. Containers need to be stopped to be deleted unless
force options is set.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was removed.

## Example Code

```js
const {$status} = await nikita.docker.rm({
  container: 'toto'
})
console.info(`Container was removed: ${$status}`)
```
