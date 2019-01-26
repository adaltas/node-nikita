
# `nikita.docker.wait`

Block until a container stops.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `container` (string)   
  Name/ID of the container, optional.
* `machine` (string)   
  Name of the docker-machine, optional if using docker-machine.
* `code` (int|array)   
  Expected code(s) returned by the command, int or array of int, default to 0.
* `code_skipped`   
  Expected code(s) returned by the command if it has no effect, executed will
  not be incremented, int or array of int.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True unless container was already stopped.

## Example

```javascript
nikita.docker.wait({
  container: 'toto'
}, function(err, status){
  console.log( err ? err.message : 'Did we really had to wait: ' + status);
})
```

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering Docker wait", level: 'DEBUG', module: 'nikita/lib/docker/wait'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validation
      return callback Error 'Missing container parameter' unless options.container?
      # rm is false by default only if options.service is true
      cmd = "wait #{options.container} | read r; return $r"
      # Construct other exec parameter
      @system.execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '@nikita/core/lib/misc/docker'
    util = require 'util'
