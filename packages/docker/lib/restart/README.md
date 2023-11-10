
# `nikita.docker.restart`

Start stopped containers or restart (stop + starts) a started container.

## Output

* `err`   
  Error object if any.   
* `$status`   
  True if container was restarted.  

## Example

```js
const {$status} = await nikita.docker.restart({
  container: 'toto'
})
console.info(`Container was started or restarted: ${$status}`)
```
