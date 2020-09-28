
# `nikita.docker.wait`

Block until a container stops.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True unless container was already stopped.

## Example

```javascript
nikita.docker.wait({
  container: 'toto'
}, function(err, status){
  console.log( err ? err.message : 'Did we really had to wait: ' + status);
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
      require: ['container']

## Handler

    handler = ({config, log, operations: {find}}) ->
      log message: "Entering Docker wait", level: 'DEBUG', module: 'nikita/lib/docker/wait'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Old implementation was `wait {container} | read r; return $r`
      @docker.tools.execute "wait #{config.container}"

## Exports

    module.exports =
      handler: handler
      schema: schema
