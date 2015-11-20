
# `docker_save(options, callback)`

Save Docker images

## Options

*   `image` (string)
    Name/ID of base image. MANDATORY
*   `machine` (string)
    Name of the docker-machine. MANDATORY if using docker-machine
*   `destination` (string)
    TAR archive destination path
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
  destination: 'test-image.tar'
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
      return callback Error 'Missing destination parameter' unless options.destination?
      # Saves image to local tmp path, than copy it
      # Uses copy (it is idempotent)
      # Construct exec command
      temp_dir = "/tmp/mecano_docker_save"
      name = "#{options.destination.split('/').pop().toString()}.#{Date.now()}"
      temp_dir_path = "#{temp_dir}/#{name}"
      cmd = " save -o #{temp_dir_path} #{options.image}"
      @mkdir
        destination: temp_dir
      , (err, executed) =>
        return callback err if err
        options.log message: "Extracting to temp_dir :#{temp_dir_path}", level: 'INFO', module: 'mecano/src/docker/save'
        docker.exec cmd, options, null, (err, executed, stdout, stderr) =>
          return callback err, executed, stdout, stderr if err
          ssh2fs.exists options.ssh, options.destination, (err, exists) =>
            return callback err if err
            if exists
              options.log message: "Target saved image already exist :#{options.destination}", level: 'INFO', module: 'mecano/src/docker/save'
              file.hash options.ssh, temp_dir_path, 'md5', (err, value_temp_dir) =>
                return callback err if err
                file.hash options.ssh, options.destination, 'md5', (err, value_dest) =>
                  return callback err, null if err
                  if value_temp_dir is value_dest
                    options.log message: "Indetical image (not overwritten):#{options.destination}", level: 'INFO', module: 'mecano/src/docker/save'
                    @remove
                      destination: temp_dir
                    , (err, executed, stdout, stderr) ->
                      return callback err, null, stdout, stderr
                  else
                    options.log message: "Not identical image (overwriting):#{options.destination}", level: 'INFO', module: 'mecano/src/docker/save'
                    @copy
                      source: temp_dir_path
                      destination: options.destination
                    @remove
                      destination: temp_dir, (err, executed, stdout, stderr) ->  return callback err, executed, stdout, stderr
            else
              options.log message: "Target saved image does not exist :#{options.destination}", level: 'INFO', module: 'mecano/src/docker/save'
              @copy
                source: temp_dir_path
                destination: options.destination
              @remove
                destination: temp_dir, (err, executed, stdout, stderr) =>  return callback err, executed, stdout, stderr
                force: true

## Modules Dependencies

    file = require('../misc').file
    util = require 'util'
    ssh2fs = require 'ssh2-fs'
    docker = require('../misc/docker')
