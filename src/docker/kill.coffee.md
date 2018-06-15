
# `nikita.docker.kill(options, [callback])`

Send signal to containers using SIGKILL or a specified signal.
Note if container is not running , SIGKILL is not executed and
return status is UNMODIFIED. If container does not exist nor is running
SIGNAL is not sent.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `container` (string)   
  Name/ID of the container, required.   
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `signal` (int|string)   
  Use a specified signal. SIGKILL by default.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was killed.

## Example

```javascript
nikita.docker.kill({
  container: 'toto',
  signal: 9
}, function(err, status){  
  console.log( err ? err.message : 'Container killed: ' + status);
})
```

## Source Code

    module.exports = (options) ->
      @log message: "Entering Docker kill", level: 'DEBUG', module: 'nikita/lib/docker/kill'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters
      return callback Error 'Missing container parameter' unless options.container?
      cmd = 'kill'
      cmd += " -s #{options.signal}" if options.signal?
      cmd += " #{options.container}"
      @system.execute
        cmd: docker.wrap options, "ps | grep '#{options.container}' | grep 'Up'"
        code_skipped: 1
      , docker.callback
      @system.execute
        if: -> @status -1
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
