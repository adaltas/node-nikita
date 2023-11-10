
# `nikita.docker.kill`

Send signal to containers using SIGKILL or a specified signal.
Note if container is not running , SIGKILL is not executed and
return status is UNMODIFIED. If container does not exist nor is running
SIGNAL is not sent.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was killed.

## Example

```js
const {$status} = await nikita.docker.kill({
  container: 'toto',
  signal: 9
})
console.info(`Container was killed: ${$status}`)
```
