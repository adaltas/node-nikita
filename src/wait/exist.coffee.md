
# `wait_exist(options, callback)`

Wait for a file or directory to exists. Status will be
set to "false" if the file already existed, considering that no
change had occured. Otherwise it will be set to "true".   

## Options  
  
*   `destination` (string|array)   
    Path to a file or directory.    
*   `interval`   
    Time interval between which we should wait before re-executing the check,
    default to 2s.     

Example:

```coffee
require 'mecano'
.wait_exist
  destination: "/path/to/file_or_directory"
.then (err, status) ->
  # Command succeed, the file now exists
```

    module.exports = (options, callback) ->
      modified = false
      # Validate parameters
      return callback Error "Missing destination: #{options.destination}" unless options.destination?
      options.destination = [options.destination] unless Array.isArray options.destination
      options.interval ?= 2000
      options.log message: "Entering wait for file", level: 'DEBUG', module: 'mecano/wait/exist'
      modified = false
      each options.destination
      .call (destination, next) =>
        count = 0
        run = ->
          count++
          options.log message: "Attempt ##{count}", level: 'INFO', module: 'mecano/wait/exist'
          ssh2fs.stat options.ssh, destination, (err, stat) ->
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
