
# `nikita.service.remove`

Remove a package or service.

## Output

* `$status`   
  Indicates if the startup behavior has changed.

## Example

```js
const {$status} = await nikita.service.remove([{
  name: 'gmetad'
})
console.info(`Package or service was removed: ${$status}`)
```
