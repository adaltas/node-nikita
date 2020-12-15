
# `nikita.docker.tools.service`

Run a container in a service mode. This module is just a wrapper for
`docker.run`. It declares the same configuration with the exeception of the
properties `detach` and `rm` which respectively default to `true` and `false`.

Indeed, in a service mode, the container must be detached and NOT removed by default
after execution. 

## Hooks

    on_action = ({config}) ->
      config.container ?= config.name

## Schema

    {schema} = require('mixme').merge require '../run'
    schema.properties.detach.default = true
    schema.properties.rm.default = false
    schema.required.push 'container'

## Handler

    handler = ({config, tools: {find, log}}) ->
      log message: "Entering Docker service", level: 'DEBUG', module: 'nikita/lib/docker/service'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Normalization
      config.detach ?= true
      config.rm ?= false
      # Validation
      @docker.run config

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema
