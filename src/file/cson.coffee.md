
# `nikita.file.cson(options, callback)`

## Options

* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `content`   
  Object to stringify.   
* `target`   
  File path where to write content to or a callback.   
* `merge`   
  Read the target if it exists and merge its content.   

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

    module.exports = (options) ->
      options.line_width ?= 160
      options.log message: "Entering file.yaml", level: 'DEBUG', module: 'nikita/lib/file/yaml'
      options.clean ?= true
      # Validate parameters
      throw Error 'Required Option: content' unless options.content
      throw Error 'Required Option: target' unless options.target
      # Start real work
      @call (_, callback) ->
        return callback() unless options.merge
        options.log message: "Get Target Content", level: 'DEBUG', module: 'nikita/lib/file/cson'
        fs.readFile options.ssh, options.target, 'utf8', (err, content) ->
          if err?.code is 'ENOENT'
            options.log message: "No Target Content To Merged", level: 'DEBUG', module: 'nikita/lib/file/cson'
            return callback()
          return callback err if err and err.code isnt 'ENOENT'
          try
            content = season.parse content
            options.content = misc.merge content, options.content
            options.log message: "Target Content Merged", level: 'DEBUG', module: 'nikita/lib/file/cson'
            callback()
          catch err
            callback err
      @call ->
        options.log message: "Serialize Content", level: 'DEBUG', module: 'nikita/lib/file/cson'
        @file
          content: season.stringify options.content
          target: options.target
          backup: options.backup

## Dependencies

    fs = require 'ssh2-fs'
    misc = require '../misc'
    season = require 'season'

## Resources

[season]: https://www.npmjs.com/package/season
