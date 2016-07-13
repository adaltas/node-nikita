
# `docker.stop(options, callback)`

Stop started containers

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `container` (string)   
    Name/ID of the container. MANDATORY   
*   `machine` (string)   
    Name of the docker-machine. MANDATORY if using docker-machine   
*   `timeout` (int)   
    Seconds to wait for stop before killing it   

## Callback parameters

*   `err`   
    Error object if any.   
*   `executed`   
    Wether the container was stoped or not.   

## Example

```javascript
mecano.docker.stop({
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

    module.exports = (options) ->
      options.log message: "Entering Docker stop", level: 'DEBUG', module: 'mecano/lib/docker/stop'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      throw Error 'Missing container parameter' unless options.container?
      # rm is false by default only if options.service is true
      cmd = 'stop'
      cmd += " -t #{options.timeout}" if options.timeout?
      cmd += " #{options.container}"
      @docker.status shy: true, options, (err, is_running) ->
        throw err if err
        if is_running
        then options.log message: "Stopping container #{options.container}", level: 'INFO', module: 'mecano/lib/docker/stop'
        else options.log message: "Container already stopped #{options.container} (Skipping)", level: 'INFO', module: 'mecano/lib/docker/stop'
        @end() unless is_running
      @execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
