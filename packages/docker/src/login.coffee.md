
# `nikita.docker.login`

Register or log in to a Docker registry server.

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
        'email':
          type: 'string'
          description: """
          User email.
          """
        'user':
          type: 'string'
          description: """
          Username of the user.
          """
        'password':
          type: 'string'
          description: """
          User password.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'

## Handler

    handler = ({config, tools: {log}}) ->
      log message: "Entering Docker login", level: 'DEBUG', module: 'nikita/lib/docker/login'
      @docker.tools.execute
        command: [
          'login'
          ...(
            ['email', 'user', 'password']
            .filter (opt) ->
              config[opt]?
            .map (opt) ->
              "-#{opt.charAt 0} #{config[opt]}"
          )
          "#{utils.string.escapeshellarg config.registry}" if config.registry?
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
      schema: schema

## Dependencies

    utils = require '@nikitajs/engine/lib/utils'
    path = require 'path'
