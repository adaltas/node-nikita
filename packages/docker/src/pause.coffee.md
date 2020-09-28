
# `nikita.docker.pause`

Pause all processes within a container.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was pulled.

## Example

```javascript
require('nikita')
.docker.pause({
  container: 'toto'
}, function(err, {status}){
  console.log( err ? err.message : 'Container paused: ' + status);
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          type: 'string'
          description: """
          Name/ID of the container.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['container']

## Handler

    handler = ({config, log, operations: {find}}) ->
      log message: "Entering Docker pause", level: 'DEBUG', module: 'nikita/lib/docker/pause'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      @docker.tools.execute
        cmd: "pause #{config.container}"

## Exports

    module.exports =
      handler: handler
      schema: schema
