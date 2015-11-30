# `docker_cp(options, callback)`

Copy files/folders from a PATH on the container to a HOSTDIR on the host

## Options

*   `container` (string)
    Name/ID of base image. MANDATORY
*   `machine` (string)
    Name of the docker-machine. MANDATORY if using docker-machine
*   `path` (string)
    path inside the container
*   `temp_dir` (boolean)
    rather use or not a temp_dir. If set to false the target file will be overwritten
    automatically by docker.(true by default)
*   `host_dir`
    path to destination directory on the host machine
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
  host_dir: '/etc/'
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
      return callback Error 'Missing path parameter' unless options.path?
      return callback Error 'Missing host_dir parameter' unless options.host_dir?
      return callback Error 'Missing container parameter' unless options.container?
      # Construct exec command

      options.temp_dir ?= 'true'
      temp_dir = "/tmp/mecano_docker_cp_#{Date.now()}"
      destination = if options.temp_dir then temp_dir else  options.host_dir
      destination_path = "#{options.host_dir}/#{options.path.split('/').pop().toString()}"
      temp_dir_path = "#{destination}/#{options.path.split('/').pop().toString()}"
      cmd = " cp #{options.container}:#{options.path} #{temp_dir}"
      ssh2fs.stat options.ssh, options.host_dir, (err, stats) =>
        if err
          if err.code == 'ENOENT'
            options.log message: "Target directory does not exist :#{options.host_dir}", level: 'INFO', module: 'mecano/src/docker/cp'
            return callback err
        else
          options.log message: "Target is not a directory :#{options.host_dir}", level: 'ERROR', module: 'mecano/src/docker/cp' unless stats.isDirectory()
          return callback err, false unless stats.isDirectory()
          options.log message: "Extracting :#{options.path} from #{options.container} to destination:#{destination}", level: 'DEBUG', module: 'mecano/src/docker/cp' unless options.temp_dir?
          options.log message: "Extracting :#{options.path} from #{options.container} to temp_dir:#{temp_dir}", level: 'DEBUG', module: 'mecano/src/docker/cp'
          docker.exec cmd, options, null, (err, copied, stdout, stderr) =>
            return callback err, copied, stdout, stderr if err or !options.temp_dir
            ssh2fs.stat options.ssh, destination_path, (err, stats) =>
              if err
                if err.code == 'ENOENT'
                  options.log message: "Target does not exist :#{destination_path}", level: 'INFO', module: 'mecano/src/docker/cp'
                  @copy
                    source: temp_dir_path
                    destination: options.host_dir, (err, executed, stdout, stderr) ->
                      return callback err, executed, stdout, stderr
                else
                  return callback err, false
              else
                if stats
                  options.log message: "Target already exist #{destination_path}", level: 'INFO', module: 'mecano/src/docker/cp'
                  file.hash options.ssh, temp_dir_path, 'md5', (err, value_temp_dir) =>
                    return callback err if err
                    file.hash options.ssh, destination_path, 'md5', (err, value_dest) =>
                      options.log message: "Identical hash for extracted file/directory", level: 'INFO', module: 'mecano/src/docker/cp' if (value_temp_dir is value_dest)
                      return callback err, null if err or (value_temp_dir is value_dest)
                      @copy
                        source: temp_dir_path
                        destination: options.host_dir, (err, executed, stdout, stderr) =>
                          return callback err, executed, stdout, stderr

## Modules Dependencies

    file = require('../misc').file
    util = require 'util'
    ssh2fs = require 'ssh2-fs'
    docker = require('../misc/docker')
