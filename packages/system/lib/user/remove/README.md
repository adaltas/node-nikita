
# `nikita.system.user.remove`

Create or modify a Unix user.

## Callback parameters

* `$status`   
  Value is "true" if user was created or modified.

## Example

```js
const {$status} = await nikita.system.user.remove({
  name: 'a_user'
})
console.log(`User removed: ${$status}`)
```
