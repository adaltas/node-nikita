
# `nikita.fs.wait`

Wait for a file or directory to exists. Status will be
set to "false" if the file already existed, considering that no
change had occured. Otherwise it will be set to "true".

## Example

```js
const {$status} = await nikita.fs.wait({
  target: '/path/to/file_or_directory'
})
console.info(`File was created: ${$status}`)
```
