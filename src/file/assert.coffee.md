
# `assert(options)`

Assert a file exists or a provided text match the content of a text file.

## Options

*   `content` (buffer, string)   
    Text to validate.   
*   `encoding` (string)   
    Content encoding, see the Node.js supported Buffer encoding.   
*   `source` (string)   
    Alias of option "target".   
*   `target` (string)   
    File storing the content to assert.   

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
      options.target ?= options.argument
      options.target ?= options.source
      throw Error 'Missing option: "target"' unless options.target
      if typeof options.content is 'string'
        options.content = Buffer.from options.content, options.encoding
      else if options.content? and not Buffer.isBuffer options.content
        throw Error "Invalid option 'content': expect string or buffer"
      @call unless: options.content?.toString(), (_, callback) ->
        fs.exists options.ssh, options.target.toString(), (err, exists) ->
          err = Error "File does not exists: #{JSON.stringify options.target}" unless exists
          callback err
      @call if: options.content?.toString(), (_, callback) ->
        fs.readFile options.ssh, options.target, (err, buffer) ->
          unless err or buffer.equals options.content
            options.error ?= "Invalid content match: expected #{JSON.stringify options.content.toString()}, got #{JSON.stringify buffer.toString()}"
            err = Error options.error 
          callback err

## Dependencies

    fs = require 'ssh2-fs'
