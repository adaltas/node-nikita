
# `nikita.service.status`

Status of a service.
Note, does not throw an error if service is not installed.

## Output

* `started`   
  Indicates if the startup behavior has changed.   

## Example

```js
const {started} = await nikita.service.status([{
  name: 'gmetad'
})
console.info(`Service status: ${started ? 'started' : 'stopped'}`)
```
