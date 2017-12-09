
# `nikita.file.yaml(options, callback)`

Write an object serialized in YAML format. Note, we are internally using the [js-yaml] module.
However, there is a subtile difference. Any key provided with value of
`undefined` or `null` will be disregarded. Within a `merge`, it get more
prowerfull and tricky: the original value will be kept if `undefined` is
provided while the value will be removed if `null` is provided.

The `file.yaml` function rely on the `file` function and accept all of its
options. It introduces the `merge` option which instruct to read the
target file if it exists and merge its parsed object with the one
provided in the `content` option.

## Options

* `append`   
  Append the content to the target file. If target does not exist,
  the file will be created. When used with the `match` and `replace` options,
  it will append the `replace` value at the end of the file if no match if
  found and if the value is a string.
* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `content`   
  Object to stringify.
* `target`   
  File path where to write content to or a callback.
* `from`   
  Replace from after this marker, a string or a regular expression.
* `local`   
  Treat the source as local instead of remote, only apply with "ssh" option.
* `indent`   
  Number of space used for indentation. Default to 2.
  * `line_width`.
  Number of max character before a new line is written. Default to 160.
* `match`   
  Replace this marker, a string or a regular expression.
* `merge`   
  Read the target if it exists and merge its content.
* `replace`   
  The content to be inserted, used conjointly with the from, to or match
  options.
* `source`   
  File path from where to extract the content, do not use conjointly with
  content.
* `to`   
  Replace to before this marker, a string or a regular expression.
* `ssh` (object|ssh2)   
  Run the action on a remote server using SSH, an ssh2 instance or an
  configuration object used to initialize the SSH connection.
* `stdout` (stream.Writable)   
  Writable EventEmitter in which the standard output of executed commands will
  be piped.
* `stderr` (stream.Writable)   
  Writable EventEmitter in which the standard error output of executed command
  will be piped.

## Callback parameters

* `err`   
  Error object if any.
* `written`   
  Number of written actions with modifications.

## Example

```js
require('nikita').file.yaml({
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
      options.line_width ?= 160
      options.log message: "Entering file.yaml", level: 'DEBUG', module: 'nikita/lib/file/yaml'
      {merge, target, content, ssh} = options
      options.clean ?= true
      # Validate parameters
      return callback Error 'Missing content' unless content
      return callback Error 'Missing target' unless target
      # Start real work
      do_get = ->
        return do_file() unless merge
        options.log message: "Get content for merge", level: 'DEBUG', module: 'nikita/lib/file/yaml'
        fs.exists ssh, target, (err, exists) ->
          return callback err if err
          return do_file() unless exists
          fs.readFile ssh, target, 'ascii', (err, c) ->
            return callback err if err and err.code isnt 'ENOENT'
            try
              yaml.safeLoadAll c, (data) ->
                data = misc.yaml.clean data, content, true
                options.content = misc.yaml.merge data, content
                do_file()
            catch error
              return callback error
      do_file = =>
        options.indent ?= 2
        if options.clean
          options.log message: "Clean content", level: 'INFO', module: 'nikita/lib/file/yaml'
          misc.ini.clean content
        options.log message: "Serialize content", level: 'DEBUG', module: 'nikita/lib/file/yaml'
        try
          options.content = yaml.safeDump options.content, noRefs:true, lineWidth: options.line_width
          @file options, header: null, (err, written) ->
            callback err, written
      do_get()

## Dependencies

    fs = require 'ssh2-fs'
    misc = require '../misc'
    yaml = require 'js-yaml'

[js-yaml]: https://github.com/nodeca/js-yaml
