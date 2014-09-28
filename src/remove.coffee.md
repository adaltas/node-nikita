
# `remove([goptions], options, callback)`

Recursively remove files, directories and links. Internally, the function
use the [rimraf](https://github.com/isaacs/rimraf) library.   

## Options

*   `source`   
    File, directory or pattern.   
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
      wrap arguments, (options, next) ->
        # Validate parameters
        options = source: options if typeof options is 'string'
        options.source ?= options.destination
        return next new Error "Missing source" unless options.source?
        # Start real work
        modified = false
        if options.ssh
          options.log? "Remove #{options.source}"
          fs.exists options.ssh, options.source, (err, exists) ->
            return next err if err
            modified = true if exists
            misc.file.remove options.ssh, options.source, (err) ->
              next err, modified
        else
          each()
          .files(options.source)
          .on 'item', (file, next) ->
            modified = true
            options.log? "Remove #{file}"
            misc.file.remove options.ssh, file, next
          .on 'both', (err) ->
            next err, modified

## Dependencies

    fs = require 'ssh2-fs'
    each = require 'each'
    misc = require './misc'
    wrap = require './misc/wrap'



