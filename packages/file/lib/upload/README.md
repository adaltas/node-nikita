
# `nikita.file.upload`

Upload a file to a remote location. Options are identical to the "write"
function with the addition of the "binary" option.

## Output

* `$status`   
  Value is "true" if file was uploaded.

## Example

```js
const {$status} = await nikita.file.upload({
  source: '/tmp/local_file',
  target: '/tmp/remote_file'
})
console.info(`File was uploaded: ${$status}`)
```
