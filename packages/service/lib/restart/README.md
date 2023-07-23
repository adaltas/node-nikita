
# `nikita.service.restart`

Restart a service.

## Output
 
* `$status`   
  Indicates if the startup behavior has changed.   

## Example

```js
const {$status} = await nikita.service.restart([{
  name: 'gmetad'
})
console.info(`Service was restarted: ${$status}`)
```
