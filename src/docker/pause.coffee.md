
# `nikita.docker.pause(options, [callback])`

Pause all processes within a container

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `container` (string)   
    Name/ID of the container. __Mandatory__   
*   `machine` (string)   
    Name of the docker-machine. __Mandatory__ if using docker-machine   
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
nikita.docker.pause({
  container: 'toto'
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

    module.exports = (options, callback) ->
      options.log message: "Entering Docker pause", level: 'DEBUG', module: 'nikita/lib/docker/pause'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      return callback Error 'Missing container parameter' unless options.container?
      cmd = "pause #{options.container}"
      @system.execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
