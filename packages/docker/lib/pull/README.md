
# `nikita.docker.pull`

Pull an image or a repository from a registry.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was pulled.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.pull({
  image: 'postgresql'
})
console.info(`Image was pulled: ${$status}`)
```
