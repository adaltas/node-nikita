
# `docker_build(options, callback)`

Register or log in to a Docker registry server.

## Options

*   `registry` (string)
    Address of the registry server. "https://index.docker.io/v1/" by default
*   `machine` (string)
    Name of the docker-machine. MANDATORY if using docker-machine
*   `email` (string)
    Email
*   `user` (string)
    Username
*   `password` (string)
    Remove intermediate containers after build. Default to false
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

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters and madatory conditions
      return callback  Error 'Missing image parameter' unless options.image?
      return callback  Error 'Can not build from Dockerfile and content' if options.content? and options.dockerfile?
      docker.get_provider options, (err,  provider) =>
        return callback err if err
        options.provider = provider
        cmd = docker.prepare_cmd provider, options.machine
        return callback cmd if util.isError cmd
        # custom command for content option
        cmd += 'docker login'
        # not mandatory options
        for opt in ['email', 'user', 'password']
          cmd += " -#{opt.charAt 0} #{options[opt]}" if options[opt]?
        cmd += " \"#{options.registry}\"" if options.registry?
        # Construct other exec parameter
        exec_opts =
          cmd: cmd
        for k in ['ssh','log', 'stdout','stderr','cwd','code','code_skipped']
          exec_opts[k] = options[k] if options[k]?
        @execute exec_opts, (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr

## Modules Dependencies

    docker = require './commons'
    path = require 'path'
    util = require 'util'
