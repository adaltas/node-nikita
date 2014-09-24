
# `remove([goptions], options, callback)`

Recursively remove files, directories and links. Internally, the function
use the [rimraf](https://github.com/isaacs/rimraf) library.   

## Options

*   `source`   
    File, directory or pattern.   
*   `destination`      
    Alias for "source".   

## Callback parameters

*   `err`   
    Error object if any.   
*   `removed`   
    Number of removed sources.   

## Simple example

```js
require('mecano').remove('./some/dir', function(err, removed){
  console.log(err ? err.message : "File removed: " + !!removed);
});
```

## Removing a directory unless a given file exists

```js
require('mecano').remove({
  source: './some/dir',
  not_if_exists: './some/file'
}, function(err, removed){
  console.log(err ? err.message : "File removed: " + !!removed);
});
```

## Removing multiple files and directories

```js
require('mecano').remove([
  { source: './some/dir', not_if_exists: './some/file' },
  './some/file'
], function(err, removed){
  console.log(err ? err.message : "File removed: " + !!removed);
});
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      result = child()
      finish = (err, removed) ->
        callback err, removed if callback
        result.end err, removed
      misc.options options, (err, options) ->
        return finish err if err
        removed = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          # Validate parameters
          options = source: options if typeof options is 'string'
          options.source ?= options.destination
          return next new Error "Missing source" unless options.source?
          # Start real work
          remove = ->
            if options.ssh
              options.log? "Remove #{options.source}"
              fs.exists options.ssh, options.source, (err, exists) ->
                return next err if err
                removed++ if exists
                misc.file.remove options.ssh, options.source, next
            else
              each()
              .files(options.source)
              .on 'item', (file, next) ->
                removed++
                options.log? "Remove #{file}"
                misc.file.remove options.ssh, file, next
              .on 'error', (err) ->
                next err
              .on 'end', ->
                next()
          conditions.all options, next, remove
        .on 'both', (err) ->
          finish err, removed
      result

## Dependencies

    fs = require 'ssh2-fs'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'



