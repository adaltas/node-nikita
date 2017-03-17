
# `nikita.file.ini(options, callback)`

Write an object as .ini file. Note, we are internally using the [ini] module.
However, there is a subtile difference. Any key provided with value of 
`undefined` or `null` will be disregarded. Within a `merge`, it get more
prowerfull and tricky: the original value will be kept if `undefined` is
provided while the value will be removed if `null` is provided.

The `file.ini` function rely on the `file` function and accept all of its
options. It introduces the `merge` option which instruct to read the
target file if it exists and merge its parsed object with the one
provided in the `content` option.

## Options   

*   `backup`   
    Create a backup, append a provided string to the filename extension or a
    timestamp if value is not a string.   
*   `clean`   
    Remove all the lines whithout a key and a value, default to "true".   
*   `content`   
    Object to stringify.   
*   `merge`   
    Read the target if it exists and merge its content.   
*   `parse`   
    User-defined function to parse the content from ini format, default to
    `require('ini').parse`, see 'misc.ini.parse_multi_brackets'.   
*   `separator`   
    Default separator between keys and values, default to " : ".   
*   `stringify`   
    User-defined function to stringify the content to ini format, default to
    `require('ini').stringify`, see 'misc.ini.stringify_square_then_curly' for
    an example.   
*   `target`   
    File path where to write content to or a callback.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `written`   
    Number of written actions with modifications.   

## Example

```js
require('nikita').ini({
  content: {
    'my_key': 'my value'
  },
  target: '/tmp/my_file'
}, function(err, written){
  console.log(err ? err.message : 'Content was updated: ' + !!written);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering file.ini", level: 'DEBUG', module: 'nikita/lib/file/ini'
      {merge, target, content, ssh} = options
      options.clean ?= true
      # Validate parameters
      return callback new Error 'Missing content' unless content
      return callback new Error 'Missing target' unless target
      # Start real work
      do_get = ->
        return do_file() unless merge
        options.log message: "Get content for merge", level: 'DEBUG', module: 'nikita/lib/file/ini'
        fs.exists ssh, target, (err, exists) ->
          return callback err if err
          return do_file() unless exists
          fs.readFile ssh, target, 'ascii', (err, c) ->
            return callback err if err and err.code isnt 'ENOENT'
            content = misc.ini.clean content, true
            parse = options.parse or misc.ini.parse
            content = misc.merge parse(c, options), content
            do_file()
      do_file = =>
        if options.clean
          options.log message: "Clean content", level: 'INFO', module: 'nikita/lib/file/ini'
          misc.ini.clean content
        options.log message: "Serialize content", level: 'DEBUG', module: 'nikita/lib/file/ini'
        stringify = options.stringify or misc.ini.stringify
        options.content = stringify content, options
        @file options, (err, written) ->
          callback err, written
      do_get()

## Dependencies

    fs = require 'ssh2-fs'
    misc = require '../misc'

[ini]: https://github.com/isaacs/ini
