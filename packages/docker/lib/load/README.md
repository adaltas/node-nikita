
# `nikita.docker.load`

Load Docker images.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was loaded.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.load({
  image: 'nikita/load_test:latest',
  machine: machine,
  source: "/tmp/nikita_load.tar"
})
console.info(`Image was loaded: ${$status}`);
```
