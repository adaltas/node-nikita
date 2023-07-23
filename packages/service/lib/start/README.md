
# `nikita.service.start`

Start a service.
Note, does not throw an error if service is not installed.

## Output

* `$status`   
  Indicates if the service was started ("true") or if it was already running 
  ("false").

## Example

```js
const {$status} = await nikita.service.start([{
  name: 'gmetad'
})
console.info(`Service was started: ${$status}`)
```
