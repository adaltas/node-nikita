
# `nikita.docker.login`

Register or log in to a Docker registry server.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.   
* `registry` (string)   
  Address of the registry server. "https://index.docker.io/v1/" by default   
* `machine` (string)   
  Name of the docker-machine, require if using docker-machine   
* `email` (string)   
  Email   
* `user` (string)   
  Username   
* `password` (string)   
  Remove intermediate containers after build. Default to false   
* `cwd` (string)   
  change the working directory for the build.   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True when the command was executed successfully.   
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.   
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.   

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering Docker login", level: 'DEBUG', module: 'nikita/lib/docker/login'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters and madatory conditions
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

    docker = require '@nikitajs/core/lib/misc/docker'
    path = require 'path'
    util = require 'util'
