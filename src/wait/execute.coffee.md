
# `wait_execute(options, callback)`

Run a command periodically and continue once the command succeed. Status will be
set to "false" if the user command succeed right away, considering that no
change had occured. Otherwise it will be set to "true".   

## Options  

*   `quorum` (number|boolean)    
    Number of minimal successful connection, 50%+1 if "true".   
*   `cmd` (string|array)   
    The commands to be executed.    
*   `interval`   
    Time interval between which we should wait before re-executing the command,
    default to 2s.   
*   `code`   
    Expected exit code to recieve to exit and call the user callback, default to "0".   
*   `code_skipped`   
    Expected code to be returned when the command failed and should be scheduled
    for later execution, default to "1".   

Example:

```coffee
require 'mecano'
.wait_execute
  cmd: "test -f /tmp/sth"
.then (err, status) ->
  # Command succeed, the file "/tmp/sth" now exists
```

    module.exports = (options, callback) ->
      modified = false
      # Validate parameters
      options = { cmd: options } if typeof options is 'string'
      return callback new Error "Missing cmd: #{options.cmd}" unless options.cmd?
      options.cmd = [options.cmd] unless Array.isArray options.cmd
      options.quorum = options.quorum
      if options.quorum and options.quorum is true  
        options.quorum = Math.ceil options.cmd.length / 2
      else unless options.quorum?
        options.quorum = options.cmd.length
      options.interval ?= 2000
      options.code_skipped ?= 1
      options.log message: "Start wait for execution", level: 'DEBUG', module: 'mecano/wait/execute'
      quorum_current = 0
      modified = false
      each options.cmd
      .call (cmd, next) =>
        count = 0
        return next() if quorum_current >= options.quorum
        run = =>
          count++
          options.log message: "Attempt ##{count}", level: 'INFO', module: 'mecano/wait/execute'
          @execute
            cmd: cmd
            code: options.code or 0
            code_skipped: options.code_skipped
          , (err, ready) =>
            if not err and not ready
              setTimeout run, options.interval
              return
            return next err if err
            options.log message: "Finish wait for execution", level: 'INFO', module: 'mecano/wait/execute'
            quorum_current++
            modified = true if count > 1
            next()
        run()
      .then (err) ->
        callback err, modified

## Dependencies

    each = require 'each'
