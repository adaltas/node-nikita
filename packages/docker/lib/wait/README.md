
# `nikita.docker.wait`

Block until a container stops.

## Output

* `err`   
  Error object if any.   
* `$status`   
  True unless container was already stopped.

## Example

```js
const {$status} = await nikita.docker.wait({
  container: 'toto'
})
console.info(`Did we really had to wait: ${$status}`)
```
