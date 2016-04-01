

# `remove(options, callback)`

Recursively remove files, directories and links.

## Options

*   `destination` (string|[string])      
    File, directory or glob (pattern matching based on wildcard characters).   
*   `source` (alias)   
    Alias for "destination".   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.  

## Callback parameters

*   `err`   
    Error object if any.   
*   `removed`   
    Number of removed files.   

## Implementation details

Files are removed localling using the [rimraf] package. The Unix "rm" utility
is used over an SSH remote connection. Porting the [rimraf] strategy over
SSH would be too slow.

## Simple example

```js
require('mecano')
.remove('./some/dir', function(err, removed){
  console.log(err ? err.message : "File removed: " + !!removed);
});
```

## Removing a directory unless a given file exists

```js
require('mecano')
.remove({
  destination: './some/dir',
  unless_exists: './some/file'
}, function(err, removed){
  console.log(err ? err.message : "File removed: " + !!removed);
});
```

## Removing multiple files and directories

```js
require('mecano')
.remove([
  { destination: './some/dir', unless_exists: './some/file' },
  './some/file'
], function(err, removed){
  console.log(err ? err.message : 'File removed: ' + !!removed);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering remove", level: 'DEBUG', module: 'mecano/lib/remove'
      # Validate parameters
      options.destination = options.argument if options.argument?
      options.destination ?= options.source
      return callback Error "Missing option: \"destination\"" unless options.destination?
      # Start real work
      modified = false
      glob options.ssh, options.destination, (err, files) ->
        return callback err if err
        each files
        .call (file, callback) ->
          modified = true
          misc.file.remove options.ssh, file, callback
        .then (err) ->
          callback err, modified

## Dependencies

    fs = require 'ssh2-fs'
    each = require 'each'
    misc = require '../misc'
    glob = require '../misc/glob'

[rimraf]: https://github.com/isaacs/rimraf
