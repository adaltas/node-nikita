
# `assert(options)`

Assert a provided text match the content of a text file

## Option properties

*   `content` (buffer, string)   
    Text to validate.   
*   `encoding` (string)   
    Content encoding, see the Node.js supported Buffer encoding.   
*   `source` (string)   
    File storing the content to assert.   
*   `target` (string)   
    Alias of option "target".   

## Callback parameters

*   `err` (Error)   
    Error if assertion failed.   

## Example

```js
mecano.assert({
  ssh: connection
  source: '/tmp/a_file'     
  content: 'nikita is around' 
}, function(err){
  console.log(err);
});
```

## Source code

    module.exports = (options) ->
      options.log message: "Entering assert", level: 'DEBUG', module: 'mecano/lib/assert'
      options.encoding ?= 'utf8'
      options.source ?= options.target
      throw Error "Required option 'content'" unless options.content
      throw Error "Required option 'source'" unless options.source
      options.error ?= "Invalid content match"
      if typeof options.content is 'string'
        options.content = Buffer.from options.content, options.encoding
      else unless Buffer.isBuffer otions.content
        throw Error "Invalid option 'content': expect string or buffer"
      @call (_, callback) ->
        fs.readFile options.source, (err, buffer) ->
          err = Error options.error unless err or buffer.equals options.content
          callback err
      

## Dependencies

    fs = require 'fs'

[backmeup]: https://github.com/adaltas/node-backmeup
