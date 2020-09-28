
# `nikita.docker.tools.checksum`

Return the checksum of image:tag, if it exists. Note, there is no corresponding
native docker command.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if command was executed.
* `checksum`   
  Image cheksum if it exist, undefined otherwise.

## Hooks

    on_action = ({config}) ->
      throw Error 'Configuration `repository` is deprecated, use `image` instead' if config.repository

## Schema

    schema =
      type: 'object'
      properties:
        'cwd':
          type: 'string'
          description: """
          Change the build working directory.
          """
        'image':
          type: 'string'
          description: """
          Name of the Docker image present in the registry.
          """
        'tag':
          type: 'string'
          default: 'latest'
          description: """
          Tag of the Docker image, default to latest.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'

## Handler

    handler = ({config, log, operations: {find}}) ->
      log message: "Entering Docker checksum", level: 'DEBUG', module: 'nikita/lib/docker/checksum'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      log message: "Getting image checksum :#{config.image}", level: 'DEBUG', module: 'nikita/lib/docker/checksum'
      # Run `docker images` with the following config:
      # - `--no-trunc`: display full checksum
      # - `--quiet`: discard headers
      {status, stdout} = await @docker.tools.execute
        boot2docker: config.boot2docker
        cmd: "images --no-trunc --quiet #{config.image}:#{config.tag}"
        compose: config.compose
        machine: config.machine
      checksum = if stdout is '' then undefined else stdout.toString().trim()
      log message: "Image checksum for #{config.image}: #{checksum}", level: 'INFO', module: 'nikita/lib/docker/checksum' if status
      status: status, checksum: checksum

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema

## Dependencies

    docker = require '../utils'
