
# `nikita.system.remove(options, [callback])`

Recursively remove files, directories and links.

## Options

* `target` (string|[string])      
  File, directory or glob (pattern matching based on wildcard characters).   
* `source` (alias)   
  Alias for "target".   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if files were removed.   

## Implementation details

Files are removed localling using the Unix "rm" utility. Porting [rimraf] over
SSH would be too slow.

## Simple example

```js
require('nikita')
.system.remove('./some/dir', function(err, status){
  console.log(err ? err.message : "File removed: " + !!status);
});
```

## Removing a directory unless a given file exists

```js
require('nikita')
.system.remove({
  target: './some/dir',
  unless_exists: './some/file'
}, function(err, status){
  console.log(err ? err.message : "File removed: " + !!status);
});
```

## Removing multiple files and directories

```js
require('nikita')
.system.remove([
  { target: './some/dir', unless_exists: './some/file' },
  './some/file'
], function(err, status){
  console.log(err ? err.message : 'File removed: ' + !!status);
});
```

## Source Code

    module.exports = (options, callback) ->
      @log message: "Entering remove", level: 'DEBUG', module: 'nikita/lib/system/remove'
      # SSH connection
      ssh = @ssh options.ssh
      # Validate parameters
      options.target = options.argument if options.argument?
      options.target ?= options.source
      return callback Error "Missing option: \"target\"" unless options.target?
      # Start real work
      glob ssh, options.target, (err, files) =>
        return callback err if err
        each files
        .call (file, callback) =>
          @log message: "Removing file #{file}", level: 'INFO', module: 'nikita/lib/system/remove'
          @system.execute
            cmd: "rm -rf '#{file}'"
          , callback
        .next (err) ->
          callback err, status: !!files.length, count: files.length

## Dependencies

    each = require 'each'
    misc = require '../misc'
    glob = require '../misc/glob'

[rimraf]: https://github.com/isaacs/rimraf
