
# `nikita.fs.base.createReadStream`

## Example

The `stream` config property receives the readable stream:

```js
buffers = []
await nikita.fs.base.createReadStream({
  target: '/path/to/file'
  stream: function(rs){
    rs.on('readable', function(){
      while(buffer = rs.read()){
        buffers.push(buffer)
      }
    })
  }
})
console.info(Buffer.concat(buffers).toString())
```

Alternatively, you can directly provide the readable function with the
`on_readable` config property:

```js
buffers = []
await nikita.fs.base.createReadStream({
  target: '/path/to/file'
  on_readable: function(rs){
    while(buffer = rs.read()){
      buffers.push(buffer)
    }
  }
})
console.info(Buffer.concat(buffers).toString())
```
