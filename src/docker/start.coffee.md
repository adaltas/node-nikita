
# `docker_restart(options, callback)`

Restart containers

## Options

*   `container` (string)   
    Name/ID of the container. MANDATORY   
*   `machine` (string)   
    Name of the docker-machine. MANDATORY if using docker-machine   
*   `attach` (boolean)   
    attach STDOUT/STDERR. False by default   
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
*   `stdout`   
    Stdout value(s) unless `stdout` option is provided.   
*   `stderr`   
    Stderr value(s) unless `stderr` option is provided.   

## Example

1- builds an image from dockerfile without any resourcess

```javascript
mecano.docker_start({
  container: 'toto',
  attach: true
}, function(err, is_true, stdout, stderr){
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
      options.log message: "Entering Docker start", level: 'DEBUG', module: 'mecano/lib/docker/start'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      throw Error 'Missing container parameter' unless options.container?
      # rm is false by default only if options.service is true
      cmd = 'start'
      cmd += ' -a' if options.attach
      cmd += " #{options.container}"
      @docker_status shy: true, options, (err, is_running) ->
        throw err if err
        if is_running
        then options.log message: "Container already started #{options.container} (Skipping)", level: 'INFO', module: 'mecano/lib/docker/start'
        else options.log message: "Starting container #{options.container}", level: 'INFO', module: 'mecano/lib/docker/start'
        @end() if is_running
      @execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
