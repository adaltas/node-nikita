
# `nikita.docker.stop`

Stop a started container.

## Output

* `err`   
  Error object if any.
* `$status`   
  True unless container was already stopped.

## Example

```js
const {$status} = await nikita.docker.stop({
  container: 'toto'
})
console.info(`Container was stopped: ${$status}`)
```
