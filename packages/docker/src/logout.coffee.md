
# `nikita.docker.logout`

Log out from a Docker registry or the one defined by the `registry` option.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `registry` (string)   
  Address of the registry server, default to "https://index.docker.io/v1/".
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `code` (int|array)   
  Expected code(s) returned by the command, int or array of int, default to 0.
* `code_skipped`   
  Expected code(s) returned by the command if it has no effect, executed will
  not be incremented, int or array of int.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True if logout.

## Schema

    schema =
      type: 'object'
      properties:
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'

## Handler

    handler = ({config, log, operations: {find}}) ->
      log message: "Entering Docker logout", level: 'DEBUG', module: 'nikita/lib/docker/logout'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Validate parameters
      return callback Error 'Missing container parameter' unless config.container?
      # rm is false by default only if config.service is true
      cmd = 'logout'
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
    util = require 'util'
