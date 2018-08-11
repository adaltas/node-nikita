
# `nikita.wait.exist`

Wait for a file or directory to exists. Status will be
set to "false" if the file already existed, considering that no
change had occured. Otherwise it will be set to "true".   

## Options  
  
* `target` (string|array)   
  Path to a file or directory.    
* `interval`   
  Time interval between which we should wait before re-executing the check,
  default to 2s.     

Example:

```js
require('nikita')
.wait.exist({
  target: "/path/to/file_or_directory"
}, function(err, status){
  // Command succeed, the file now exists
})
```

## Source Code

    module.exports = (options, callback) ->
      @log message: "Entering wait.exists", level: 'DEBUG', module: 'nikita/lib/wait/exist'
      # SSH connection
      ssh = @ssh options.ssh
      status = false
      # Validate parameters
      return callback Error "Missing target: #{options.target}" unless options.target?
      options.target = [options.target] unless Array.isArray options.target
      options.interval ?= 2000
      @log message: "Entering wait for file", level: 'DEBUG', module: 'nikita/wait/exist'
      status = false
      each options.target
      .call (target, next) =>
        count = 0
        run = =>
          count++
          @log message: "Attempt ##{count}", level: 'INFO', module: 'nikita/wait/exist'
          @fs.stat ssh: options.ssh, target: options.target, (err) ->
            return next err if err and err.code isnt 'ENOENT'
            return setTimeout run, options.interval if err
            @log message: "Finish wait for file", level: 'INFO', module: 'nikita/wait/exist'
            status = true if count > 1
            next()
        run()
      .next (err) ->
        callback err, status

    each = require 'each'
