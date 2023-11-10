
# `nikita.docker.start`

Start a container.

## Output

* `err`   
  Error object if any.
* `$status`   
  True unless container was already started.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.start({
  container: 'toto',
  attach: true
})
console.info(`Container was started: ${$status}`)
```
