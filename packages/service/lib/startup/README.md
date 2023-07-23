
# `nikita.service.startup`

Activate or desactivate a service on startup.

## Output

* `$status`   
  Indicates if the startup behavior has changed.

## Example

```js
const {$status} = await nikita.service.startup([{
  name: 'gmetad',
  startup: false
})
console.info(`Service was desactivated on startup: ${$status}`)
```
