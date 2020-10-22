
# `nikita.docker.unpause`

Unpause all processes within a container.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `container` (string)   
  Name/ID of the container, required.
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was unpaused.

## Example

```javascript
require('nikita')
.docker.pause({
  container: 'toto'
}, function(err, {status}){
  console.log( err ? err.message : 'Container was unpaused: ' + status);
})
```

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

    handler = ({config, log, tools: {find}}) ->
      log message: "Entering Docker unpause", level: 'DEBUG', module: 'nikita/lib/docker/unpause'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Validation
      throw Error 'Missing container parameter' unless config.container?
      @docker.tools.execute
        cmd: "unpause #{config.container}"

## Exports

    module.exports =
      handler: handler
      schema: schema
