
# `mecano.system.remove(options, [callback])`

Recursively remove files, directories and links.

## Options

*   `target` (string|[string])      
    File, directory or glob (pattern matching based on wildcard characters).   
*   `source` (alias)   
    Alias for "target".   

## Callback parameters

*   `err`   
    Error object if any.   
*   `status`   
    Value is "true" if files were removed.   

## Implementation details

Files are removed localling using the [rimraf] package. The Unix "rm" utility
is used over an SSH remote connection. Porting [rimraf] over SSH would be too 
slow.

## Simple example

```js
require('mecano')
.system.remove('./some/dir', function(err, status){
  console.log(err ? err.message : "File removed: " + !!status);
});
```

## Removing a directory unless a given file exists

```js
require('mecano')
.system.remove({
  target: './some/dir',
  unless_exists: './some/file'
}, function(err, status){
  console.log(err ? err.message : "File removed: " + !!status);
});
```

## Removing multiple files and directories

```js
require('mecano')
.system.remove([
  { target: './some/dir', unless_exists: './some/file' },
  './some/file'
], function(err, status){
  console.log(err ? err.message : 'File removed: ' + !!status);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering remove", level: 'DEBUG', module: 'mecano/lib/system/remove'
      # Validate parameters
      options.target = options.argument if options.argument?
      options.target ?= options.source
      return callback Error "Missing option: \"target\"" unless options.target?
      # Start real work
      glob options.ssh, options.target, (err, files) ->
        return callback err if err
        status = false
        each files
        .call (file, callback) ->
          status = true
          misc.file.remove options.ssh, file, callback
        .then (err) ->
          callback err, status

## Dependencies

    each = require 'each'
    misc = require '../misc'
    glob = require '../misc/glob'

[rimraf]: https://github.com/isaacs/rimraf
