
# `nikita.fs.readFile`

Reads the entire contents of a file.

## Example

```js
const {data} = await nikita.fs.readFile({
  target: `/tmp/a_file`,
  encoding: 'ascii'
})
console.info(data)
```
