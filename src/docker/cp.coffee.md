# `docker_cp(options, callback)`

Copy files/folders from a PATH on the container to a HOSTDIR on the host

## Options

*   `container` (string)
    Name/ID of base image. MANDATORY
*   `machine` (string)
    Name of the docker-machine. MANDATORY if using docker-machine
*   `source` (string)
    path inside the container
*   `destination`
    path to destination on the host machine
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
      return callback Error 'Missing source parameter' unless options.source?
      return callback Error 'Missing destination parameter' unless options.destination?
      return callback Error 'Missing container parameter' unless options.container?
      # Construct exec command
      cache = "/tmp/mecano_docker_cp_#{Date.now()}"
      destination_path = "#{options.destination}/#{options.source.split('/').pop().toString()}"
      cache_path = "#{cache}/#{options.source.split('/').pop().toString()}"
      cmd = " cp #{options.container}:#{options.source} #{cache}"
      docker.exec cmd, options, null, (err, copied, stdout, stderr) =>
        return callback err, copied, stdout, stderr if err
        ssh2fs.exists options.ssh, destination_path, (err, exists) =>
          return callback err if err
          if exists
            file.hash options.ssh, cache_path, 'md5', (err, value_cache) =>
              return callback err if err
              file.hash options.ssh, destination_path, 'md5', (err, value_dest) =>
                return callback err, null if err or (value_cache is value_dest)
                @copy
                  source: cache_path
                  destination: options.destination, (err, executed, stdout, stderr) =>
                    return callback err, executed, stdout, stderr
          else
            @copy
              source: cache_path
              destination: options.destination, (err, executed, stdout, stderr) ->
                return callback err, executed, stdout, stderr

## Modules Dependencies

    file = require('../misc').file
    util = require 'util'
    ssh2fs = require 'ssh2-fs'
    docker = require('../misc/docker')
