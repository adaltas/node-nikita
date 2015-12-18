
# `docker_save(options, callback)`

Save Docker images

## Options

*   `image` (string)
    Name/ID of base image. MANDATORY
*   `machine` (string)
    Name of the docker-machine. MANDATORY if using docker-machine
*   `output` (string). MANDATORY
    TAR archive output path
*   `code` (int | array)
    Expected code(s) returned by the command, int or array of int, default to 0.
*   `code_skipped`
    Expected code(s) returned by the command if it has no effect, executed will
    not be incremented, int or array of int.
*   `log`
    Function called with a log related messages.
*   `ssh` (object | ssh2)
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

```javascript
mecano.docker({
  ssh: ssh
  output: 'test-image.tar'
  image: 'test-image'
  compression: 'gzip'
  entrypoint: '/bin/true'
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

    module.exports = (options, callback) ->
      # Validate parameters
      return callback Error 'Missing image parameter' unless options.image?
      return callback Error 'Missing output parameter' unless options.output?
      # Saves image to local tmp path, than copy it
      cmd = " save -o #{options.output}  #{options.image}"
      options.log message: "Extracting image #{options.output} to file:#{options.image}", level: 'INFO', module: 'mecano/lib/docker/save'
      @execute
        cmd: docker.wrap options, cmd
      , (err, done, stdout, stderr) -> callback err, done, stdout, stderr

## Modules Dependencies

    util = require 'util'  
    docker = require('../misc/docker')
