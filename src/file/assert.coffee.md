
# `mecano.file.assert(options)`

Assert a file exists or a provided text match the content of a text file.

## Options

*   `content` (buffer|string)   
    Text to validate.   
*   `encoding` (string)   
    Content encoding, see the Node.js supported Buffer encoding.   
*   `md5` (string)   
    Validate signature.   
*   `mode` (string)   
    Validate file permissions.   
*   `not` (boolean)   
    Negate the validation.   
*   `sha1` (string)   
    Validate signature.   
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
      # Assert file exists
      @call
        unless: options.content or options.md5 or options.sha1 or options.mode
      , (_, callback) ->
        fs.exists options.ssh, options.target.toString(), (err, exists) ->
          unless options.not
            err = Error "File does not exists: #{JSON.stringify options.target}" unless exists
          else
            err = Error "File exists: #{JSON.stringify options.target}" if exists
          callback err
      # Assert content match
      @call
        if: options.content
      , (_, callback) ->
        fs.readFile options.ssh, options.target, (err, buffer) ->
          return callback err if err
          unless options.not
            unless buffer.equals options.content
              options.error ?= "Invalid content match: expect #{JSON.stringify options.content.toString()} and got #{JSON.stringify buffer.toString()}"
              err = Error options.error
          else
            if buffer.equals options.content
              options.error ?= "Unexpected content match: #{JSON.stringify options.content.toString()}"
              err = Error options.error
          callback err
      # Assert content match
      (algo = 'md5'; hash = options.md5) if options.md5
      (algo = 'sha1'; hash = options.sha1) if options.sha1
      @call
        if: algo
      , (_, callback) ->
        file.hash options.ssh, options.target, algo, (err, h) =>
          return callback Error "Target does not exists: #{options.target}" if err?.code is 'ENOENT'
          unless options.not
            err = Error "Invalid #{algo} signature: expect #{JSON.stringify hash} and got #{JSON.stringify h}" if hash isnt h
          else
            err = Error "Matching #{algo} signature: #{JSON.stringify hash}" if hash is h
          callback err
      # Assert file permissions
      @call
        if: options.mode
      , (_, callback) ->
        fs.stat options.ssh, options.target, (err, stat) ->
          return callback Error "Target does not exists: #{options.target}" if err?.code is 'ENOENT'
          unless options.not
            err = Error "Invalid mode: expect #{pad 4, misc.mode.stringify(options.mode), '0'} and got #{misc.mode.stringify(stat.mode).substr -4}" unless misc.mode.compare options.mode, stat.mode
          else
            err = Error "Unexpected valid mode: #{pad 4, misc.mode.stringify(options.mode), '0'}" if misc.mode.compare options.mode, stat.mode
          callback err

## Dependencies

    pad = require 'pad'
    fs = require 'ssh2-fs'
    file = require '../misc/file'
    misc = require '../misc'
