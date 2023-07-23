
# `nikita.service.stop`

Stop a service.
Note, does not throw an error if service is not installed.

## Output

* `$status`   
  Indicates if the service was stopped ("true") or if it was already stopped 
  ("false").

## Example

```js
const {$status} = await nikita.service.stop([{
  name: 'gmetad'
})
console.info(`Service was stopped: ${$status}`)
```
