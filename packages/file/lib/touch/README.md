
# `nikita.file.touch`

Create a empty file if it does not yet exists.

## Implementation details

Status will only be true if the file was created.

## Output

* `$status`   
  Value is "true" if file was created or modified.   

## Example

```js
const {$status} = await nikita.file.touch({
  target: '/tmp/a_file'
})
console.info(`File was touched: ${$status}`)
```
