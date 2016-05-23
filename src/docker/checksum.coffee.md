
# `docker_build(options, callback)`

Return the checksum of repository:tag, if it exists. Function not native to docker.

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `image` (string)   
    Name of the image. MANDATORY
*   `repository` (string)   
    Alias of image
*   `machine` (string)   
    Name of the docker-machine. MANDATORY if using docker-machine   
*   `code`   (int|array)   
    Expected code(s) returned by the command, int or array of int, default to 0.   
*   `code_skipped`   
    Expected code(s) returned by the command if it has no effect, executed will
    not be incremented, int or array of int.   
*   `cwd` (string)   
    change the working directory for the build.   
*   `log`   
    Function called with a log related messages.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `tag` (string)   
    Tag of the image. Default to latest   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `status`   
    True if command was executed.   
*   `checksum`   
    Image cheksum if it exist, false otherwise.   

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering Docker checksum", level: 'DEBUG', module: 'mecano/lib/docker/checksum'
      # Validate parameters and mandatory conditions
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      options.image ?= options.repository
      return callback Error 'Missing repository parameter' unless options.image?
      options.tag ?= 'latest'
      cmd = "images --no-trunc | grep '#{options.image}' | grep '#{options.tag}' | awk '{ print $3 }'"
      options.log message: "Getting image checksum :#{options.image}", level: 'INFO', module: 'mecano/lib/docker/checksum'
      @execute
        cmd: docker.wrap options, cmd
      , (err, executed, stdout, stderr) ->
        checksum = if stdout is '' then false else stdout.toString().trim()
        options.log message: "Image checksum for #{options.image}: #{checksum}", level: 'INFO', module: 'mecano/lib/docker/checksum' if executed
        return callback err, executed, checksum


## Modules Dependencies

    docker = require '../misc/docker'
