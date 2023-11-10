
# `nikita.docker.pause`

Pause all processes within a container.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was pulled.

## Example

```js
const {$status} = await nikita.docker.pause({
  container: 'toto'
})
console.info(`Container was paused: ${$status}`)
```
