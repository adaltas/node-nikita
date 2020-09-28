
# `nikita.volume_rm`

Remove a volume.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True is volume was removed.

## Example

```javascript
nikita.docker.volume_rm({
  name: 'my_volume'
}, function(err, status){
  console.log( err ? err.message : 'Volume removed: ' + status);
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'name':
          type: 'string'
          description: """
          Specify volume name.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'

## Handler

    handler = ({config, log, operations: {find}}) ->
      log message: "Entering Docker volume_rm", level: 'DEBUG', module: 'nikita/lib/docker/volume_rm'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Validation
      throw Error "Missing required option name" unless config.name
      @docker.tools.execute
        cmd: "volume rm #{config.name}"
        code: 0
        code_skipped: 1

## Exports

    module.exports =
      handler: handler
      schema: schema
