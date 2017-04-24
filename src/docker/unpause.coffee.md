
# `nikita.docker.unpause(options, [callback])`

Unpause all processes within a container

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.   
* `container` (string)   
  Name/ID of the container. __Mandatory__   
* `machine` (string)   
  Name of the docker-machine. __Mandatory__ if using docker-machine   

## Callback parameters

* `err`   
  Error object if any.   
* `executed`   
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
      options.log message: "Entering Docker unpause", level: 'DEBUG', module: 'nikita/lib/docker/unpause'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      return callback Error 'Missing container parameter' unless options.container?
      @system.execute
        cmd: docker.wrap options, "unpause #{options.container}"
      , -> docker.callback callback, arguments...

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
