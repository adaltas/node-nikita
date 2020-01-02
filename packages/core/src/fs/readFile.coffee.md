
# `nikita.fs.readFile(options, callback)`

Options:

* `target` (string)   
  Path of the file to read; required.
* `encoding` (string)
  Return a string with a particular encoding, otherwise a buffer is returned; 
  optional.

Exemple:

```js
require('nikita')
.fs.readFile({
  target: "#{scratch}/a_file",
  encoding: 'ascii'
}, function(err, {data}){
  assert(data, 'hello')
})
```

## Source Code

    module.exports = status: false, log: false, handler: ({metadata, options}, callback) ->
      @log message: "Entering fs.readFile", level: 'DEBUG', module: 'nikita/lib/fs/readFile'
      # Normalize options
      options.target = metadata.argument if metadata.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      buffers = []
      @fs.createReadStream
        target: options.target
        on_readable: (rs) ->
          while buffer = rs.read()
            buffers.push buffer
      , (err) ->
        data = Buffer.concat buffers
        data = data.toString options.encoding if options.encoding
        callback err, data: data
