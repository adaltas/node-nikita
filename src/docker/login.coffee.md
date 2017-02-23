
# `mecano.docker.build(options, [callback])`

Register or log in to a Docker registry server.

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `registry` (string)   
    Address of the registry server. "https://index.docker.io/v1/" by default   
*   `machine` (string)   
    Name of the docker-machine. __Mandatory__ if using docker-machine   
*   `email` (string)   
    Email   
*   `user` (string)   
    Username   
*   `password` (string)   
    Remove intermediate containers after build. Default to false   
*   `cwd` (string)   
    change the working directory for the build.   

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
      options.log message: "Entering Docker login", level: 'DEBUG', module: 'mecano/lib/docker/login'
      # Validate parameters and madatory conditions
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      return callback  Error 'Missing image parameter' unless options.image?
      return callback  Error 'Can not build from Dockerfile and content' if options.content? and options.dockerfile?
      cmd = 'login'
      for opt in ['email', 'user', 'password']
        cmd += " -#{opt.charAt 0} #{options[opt]}" if options[opt]?
      cmd += " \"#{options.registry}\"" if options.registry?
      @system.execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    path = require 'path'
    util = require 'util'
