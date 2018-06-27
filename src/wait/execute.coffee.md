
# `nikita.wait.execute(options, [callback])`

Run a command periodically and continue once the command succeed. Status will be
set to "false" if the user command succeed right away, considering that no
change had occured. Otherwise it will be set to "true".   

## Options  

* `quorum` (number|boolean)    
  Number of minimal successful connection, 50%+1 if "true".   
* `cmd` (string|array)   
  The commands to be executed.    
* `interval`   
  Time interval between which we should wait before re-executing the command,
  default to 2s.   
* `code`   
  Expected exit code to recieve to exit and call the user callback, default to "0".   
* `code_skipped`   
  Expected code to be returned when the command failed and should be scheduled
  for later execution, default to "1".   
* `stdin_log` (boolean)   
  Pass stdin output to the logs of type "stdin_stream", default is "true".
* `stdout_log` (boolean)   
  Pass stdout output to the logs of type "stdout_stream", default is "true".
* `stderr_log` (boolean)   
  Pass stderr output to the logs of type "stderr_stream", default is "true".

## Example

```js
require('nikita')
.wait.execute({
  cmd: "test -f /tmp/sth"
}, function(err, status){
  // Command succeed, the file "/tmp/sth" now exists
})
```

## Source Code

    module.exports = (options, callback) ->
      @log message: "Entering wait for execution", level: 'DEBUG', module: 'nikita/lib/wait/execute'
      # Validate parameters
      options.cmd ?= options.argument if typeof options.argument?
      return callback Error "Missing cmd: #{options.cmd}" unless options.cmd?
      options.cmd = [options.cmd] unless Array.isArray options.cmd
      options.quorum = options.quorum
      if options.quorum and options.quorum is true
        options.quorum = Math.ceil options.cmd.length / 2
      else unless options.quorum?
        options.quorum = options.cmd.length
      options.interval ?= 2000
      options.code_skipped ?= 1
      @log message: "Entering wait for execution", level: 'DEBUG', module: 'nikita/lib/wait/execute'
      quorum_current = 0
      modified = false
      each options.cmd
      .call (cmd, next) =>
        count = 0
        return next() if quorum_current >= options.quorum
        run = =>
          count++
          @log message: "Attempt ##{count}", level: 'INFO', module: 'nikita/lib/wait/execute'
          @system.execute
            cmd: cmd
            code: options.code or 0
            code_skipped: options.code_skipped
            stdin_log: options.stdin_log
            stdout_log: options.stdout_log
            stderr_log: options.stderr_log
          , (err, {status}) =>
            if not err and not status
              setTimeout run, options.interval
              return
            return next err if err
            @log message: "Finish wait for execution", level: 'INFO', module: 'nikita/lib/wait/execute'
            quorum_current++
            modified = true if count > 1
            next()
        run()
      .next (err) ->
        callback err, modified

## Dependencies

    each = require 'each'
