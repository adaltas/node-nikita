
# `nikita.fs.base.readFile`

Reads the entire contents of a file.

## Example

```js
const {data} = await nikita.fs.base.readFile({
  target: `/tmp/a_file`,
  encoding: 'ascii'
})
console.info(data)
```
