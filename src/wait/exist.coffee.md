
# `mecano.wait.exist(options, [callback])`

Wait for a file or directory to exists. Status will be
set to "false" if the file already existed, considering that no
change had occured. Otherwise it will be set to "true".   

## Options  
  
*   `target` (string|array)   
    Path to a file or directory.    
*   `interval`   
    Time interval between which we should wait before re-executing the check,
    default to 2s.     

Example:

```coffee
require 'mecano'
.wait.exist
  target: "/path/to/file_or_directory"
.then (err, status) ->
  # Command succeed, the file now exists
```

## Source Code

    module.exports = (options, callback) ->
      modified = false
      # Validate parameters
      return callback Error "Missing target: #{options.target}" unless options.target?
      options.target = [options.target] unless Array.isArray options.target
      options.interval ?= 2000
      options.log message: "Entering wait for file", level: 'DEBUG', module: 'mecano/wait/exist'
      modified = false
      each options.target
      .call (target, next) =>
        count = 0
        run = ->
          count++
          options.log message: "Attempt ##{count}", level: 'INFO', module: 'mecano/wait/exist'
          ssh2fs.stat options.ssh, target, (err, stat) ->
            return next err if err and err.code isnt 'ENOENT'
            return setTimeout run, options.interval if err
            options.log message: "Finish wait for file", level: 'INFO', module: 'mecano/wait/exist'
            modified = true if count > 1
            next()
        run()
      .then (err) ->
        callback err, modified

    each = require 'each'
    ssh2fs = require 'ssh2-fs'
