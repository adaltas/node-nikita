
# `remove(options, [goptions], callback)`

Recursively remove files, directories and links.

## Options

*   `source`   
    File, directory or glob (pattern matching based on wildcard characters).   
*   `destination`      
    Alias for "source".   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.  

## Callback parameters

*   `err`   
    Error object if any.   
*   `removed`   
    Number of removed sources.   

## Implementation details

Files are removed localling using the [rimraf] package. The Unix "rm" utility
is used over an SSH remote connection. Porting the [rimraf] strategy over
SSH would be too slow.

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
  console.log(err ? err.message : 'File removed: ' + !!removed);
});
```

## Source Code

    module.exports = (options, callback) ->
      wrap @, arguments, (options, callback) ->
        # Validate parameters
        options = source: options if typeof options is 'string'
        options.source ?= options.destination
        return callback new Error "Missing source" unless options.source?
        # Start real work
        modified = false
        glob options.ssh, options.source, (err, files) ->
          return callback err if err
          each(files)
          .on 'item', (file, callback) ->
            modified = true
            misc.file.remove options.ssh, file, callback
          .on 'both', (err) ->
            callback err, modified

## Dependencies

    fs = require 'ssh2-fs'
    each = require 'each'
    misc = require './misc'
    wrap = require './misc/wrap'
    glob = require './misc/glob'

[rimraf]: https://github.com/isaacs/rimraf

