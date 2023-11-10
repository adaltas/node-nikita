
# `nikita.docker.unpause`

Unpause all processes within a container.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was unpaused.

## Example

```js
const {$status} = await nikita.docker.unpause({
  container: 'toto'
})
console.info(`Container was unpaused: ${$status}`)
```
