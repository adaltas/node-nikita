
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

## Schema

    schema =
      type: 'object'
      properties:
        '':
          type: ''
          description: """
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'

## Handler

    handler = ({config, log, operations: {find}}) ->
      log message: "Entering Docker login", level: 'DEBUG', module: 'nikita/lib/docker/login'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Validate parameters and madatory conditions
      return callback  Error 'Missing image parameter' unless config.image?
      return callback  Error 'Can not build from Dockerfile and content' if config.content? and config.dockerfile?
      cmd = 'login'
      for opt in ['email', 'user', 'password']
        cmd += " -#{opt.charAt 0} #{config[opt]}" if config[opt]?
      cmd += " \"#{config.registry}\"" if config.registry?
      @execute
        cmd: docker.wrap config, cmd
      , docker.callback

## Exports

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    docker = require './utils'
    path = require 'path'
    util = require 'util'
