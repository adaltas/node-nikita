
# `docker_unpause(options, callback)`

Unpause all processes within a container

## Options

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
mecano.docker_pause({
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
      docker.get_provider options, (err,  provider) =>
        return callback err if err
        options.provider = provider
        cmd = docker.prepare_cmd provider, options.machine
        return callback cmd if util.isError cmd
        cmd += 'docker unpause '
        cmd += options.container
        # Construct other exec parameter
        opts = docker.get_options cmd, options
        @execute opts, (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr
        
## Modules Dependencies

    docker = require './commons'
    util = require 'util'
