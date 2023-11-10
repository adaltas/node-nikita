
# `nikita.docker.save`

Save Docker images.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was saved.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.save({
  image: 'nikita/load_test:latest',
  output: `${scratch}/nikita_saved.tar`,
})
console.info(`Container was saved: ${$status}`)
```
