
# `nikita.docker_rmi`

Remove images. All container using image should be stopped to delete it unless
force options is set.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if image was removed.

## Hook

    on_action = ({config, metadata}) ->
      config.image = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        # ...docker.wrap_schema
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
        'no_prune':
          type: 'boolean'
          description: """
          Do not delete untagged parents.
          """
        'tag':
          type: 'string'
          description: """
          Tag of the Docker image, default to latest.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['image']

## Handler

    handler = ({config, log, tools: {find}}) ->
      log message: "Entering Docker rmi", level: 'DEBUG', module: 'nikita/lib/docker/rmi'
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      await @docker.tools.execute
        cmd: [
          'images'
          "| grep '#{config.image} '"
          "| grep ' #{config.tag} '" if config.tag?
        ].join ' '
        code_skipped: [1]
      await @docker.tools.execute
        cmd: [
          'rmi'
          (
            ['force', 'no_prune']
            .filter (opt) -> config[opt]?
            .map (opt) -> " --#{opt.replace '_', '-'}"
          )
           " #{config.image}"
           ":#{config.tag}" if config.tag?
        ].join ''
        if: ({parent}) ->
          parent.parent.tools.status -1

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema

## Dependencies

    docker = require './utils'
    util = require 'util'
