
# `nikita.docker.volume_rm`

Remove a volume.

## Output

* `err`   
  Error object if any.
* `$status`   
  True is volume was removed.

## Example

```js
const {$status} = await nikita.docker.volume_rm({
  name: 'my_volume'
})
console.info(`Volume was removed: ${$status}`)
```
