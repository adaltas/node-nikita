
# `nikita.docker.logout`

Log out from a Docker registry or the one defined by the `registry` option.

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
        'registry':
          type: 'string'
          description: """
          Address of the registry server, default to "https://index.docker.io/v1/".
          """

## Handler

    handler = ({config, tools: {log}}) ->
      log message: "Entering Docker logout", level: 'DEBUG', module: 'nikita/lib/docker/logout'
      # Validate parameters
      return callback Error 'Missing container parameter' unless config.container?
      # rm is false by default only if config.service is true
      command = 'logout'
      command += " \"#{config.registry}\"" if config.registry?
      @execute
        command: utils.wrap config, command
      , docker.callback

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        schema: schema

## Dependencies

    utils = require './utils'
