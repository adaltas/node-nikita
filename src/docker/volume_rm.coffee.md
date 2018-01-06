
# `nikita.volume_rm(options, [callback])`

Remove a volume. 

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `container` (string|array).   
  Name or Id of the container, required.   
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `name` (string)   
  Specify volume name.

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

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker volume_rm", level: 'DEBUG', module: 'nikita/lib/docker/volume_rm'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validation
      throw Error "Missing required option name" unless options.name
      @system.execute
        cmd: docker.wrap options, "volume rm #{options.name}"
        code: 0
        code_skipped: 1

## Modules Dependencies

    docker = require '../misc/docker'
