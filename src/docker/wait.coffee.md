
# `docker_wait(options, callback)`

Block until a container stops

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `container` (string)   
    Name/ID of the container. MANDATORY   
*   `machine` (string)   
    Name of the docker-machine. MANDATORY if using docker-machine   
*   `code` (int|array)   
    Expected code(s) returned by the command, int or array of int, default to 0.   
*   `code_skipped`   
    Expected code(s) returned by the command if it has no effect, executed will
    not be incremented, int or array of int.   
*   `log`   
    Function called with a log related messages.   
*   `ssh` (object|ssh2)
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `executed`   
    if command was executed   

## Example

```javascript
mecano.docker_wait({
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
      options.log message: "Entering Docker wait", level: 'DEBUG', module: 'mecano/lib/docker/wait'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      return callback Error 'Missing container parameter' unless options.container?
      # rm is false by default only if options.service is true
      cmd = "wait #{options.container} | read r; return $r"
      # Construct other exec parameter
      @execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
