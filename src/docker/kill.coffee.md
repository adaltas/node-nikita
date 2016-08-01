
# `mecano.docker.kill(options, [callback])`

Send signal to containers using SIGKILL or a specified signal.
Note if container is not running , SIGKILL is not executed and
return status is UNMODIFIED. If container does not exist nor is running
SIGNAL is not sent.

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `container` (string)   
    Name/ID of the container. __Mandatory__   
*   `machine` (string)   
    Name of the docker-machine. __Mandatory__ if using docker-machine.   
*   `signal` (int|string)   
    Use a specified signal. SIGKILL by default   
*   `code` (int|array)   
    Expected code(s) returned by the command, int or array of int, default to 0.   
*   `code_skipped`   
    Expected code(s) returned by the command if it has no effect, executed will
    not be incremented, int or array of int.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `executed`   
    if command was executed   

## Example

```javascript
mecano.docker.kill({
  container: 'toto'
  signal: 9
}, function(err, is_true){
  if(err){
    console.log(err.message);
  }else if(is_true){
    console.log('OK!');
  }else{
    console.log('Ooops!');
  }
})
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker kill", level: 'DEBUG', module: 'mecano/lib/docker/kill'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      return callback Error 'Missing container parameter' unless options.container?
      cmd = 'kill'
      cmd += " -s #{options.signal}" if options.signal?
      cmd += " #{options.container}"
      @execute
        cmd: docker.wrap options, "ps | grep '#{options.container}' | grep 'Up'"
        code_skipped: 1
      , docker.callback
      @execute
        if: -> @status -1
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
