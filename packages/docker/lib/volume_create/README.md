
# `nikita.docker.volume_create`

Create a volume.

## Output

* `err`   
  Error object if any.   
* `$status`   
  True is volume was created.

## Example

```js
const {$status} = await nikita.docker.volume_create({
  name: 'my_volume'
})
console.info(`Volume was created: ${$status}`)
```
