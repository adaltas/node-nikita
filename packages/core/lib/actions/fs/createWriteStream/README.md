
# `nikita.fs.createWriteStream`

## Example

```js
const {$status} = await nikita.fs.createWriteStream({
  target: '/path/to/file'
  stream: function(ws){
    ws.write('some content')
    ws.end()
  }
})
console.info(`Stream was created: ${$status}`)
```
