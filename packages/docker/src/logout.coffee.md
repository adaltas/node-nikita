
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

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering Docker logout", level: 'DEBUG', module: 'nikita/lib/docker/logout'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters
      return callback Error 'Missing container parameter' unless options.container?
      # rm is false by default only if options.service is true
      cmd = 'logout'
      cmd += " \"#{options.registry}\"" if options.registry?
      @system.execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '@nikita/core/lib/misc/docker'
    util = require 'util'
