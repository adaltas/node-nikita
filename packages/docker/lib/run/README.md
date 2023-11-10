
# `nikita.docker.run`

Run Docker Containers

## Output

* `err`   
  Error object if any.
* `$status`   
  True unless contaianer was already running.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.run({
  name: 'myContainer'
  image: 'test-image'
  env: ["FOO=bar",]
  entrypoint: '/bin/true'
})
console.info(`Container was run: ${$status}`)
```
