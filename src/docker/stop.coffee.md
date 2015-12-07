
# `docker_stop(options, callback)`

Stop started containers

## Options

*   `container` (string)
    Name/ID of the container. MANDATORY
*   `machine` (string)
    Name of the docker-machine. MANDATORY if using docker-machine
*   `timeout` (int)
    Seconds to wait for stop before killing it
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
mecano.docker_stop({
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
      # Validate parameters
      return callback Error 'Missing container parameter' unless options.container?
      # rm is false by default only if options.service is true
      cmd = ' stop '
      cmd += "-t #{options.timeout} " if options.timeout?
      cmd += options.container
      docker_status options, (err, is_running) ->
        options.log message: "Container already stopped #{options.container} (Skipping)", level: 'INFO', module: 'mecano/lib/docker/start' if !is_running
        return callback err, is_running if err or !is_running
        options.log message: "Stopping container #{options.container}", level: 'INFO', module: 'mecano/lib/docker/stop'
        docker.exec cmd, options, false, (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr

## Modules Dependencies

    docker_status = require './status'
    docker = require '../misc/docker'
    util = require 'util'
