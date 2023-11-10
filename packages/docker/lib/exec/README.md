
# `nikita.docker.exec`

Run a command in a running container

## Output

* `err`   
  Error object if any.   
* `$status`   
  True if command was executed in container.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.   
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.   

## Example

```js
const {$status} = await nikita.docker.exec({
  container: 'myContainer',
  command: '/bin/bash -c "echo toto"'
})
console.info(`Command was executed: ${$status}`)
```
