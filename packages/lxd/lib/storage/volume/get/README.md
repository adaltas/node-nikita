
# `nikita.lxc.storage.volume.get`

Get a storage volume in the selected pool.

## Output parameters

* `$status`
  True if the volume was obtained.
* `data`
  The data returned by the API call.

## Example

```js
const {data} = await @lxc.storage.volume.get({
  pool = 'default',
  name = 'test',
})
console.info(`The volume informations are: ${data}`)
```
