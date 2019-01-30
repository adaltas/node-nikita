
# `nikita.volume_create`

Create a volume. 

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `driver` (string)   
  Specify volume driver name.
* `label` (string|array)   
  Set metadata for a volume.
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `name` (string)   
  Specify volume name.
* `opt` (string|array)   
  Set driver specific options.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True is volume was created.

## Example

```javascript
require('nikita')
.docker.pause({
  name: 'my_volume'
}, function(err, status){
  console.log( err ? err.message : 'Volume created: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering Docker volume_create", level: 'DEBUG', module: 'nikita/lib/docker/volume_create'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Normalize options
      options.label = [options.label] if typeof options.label is 'string'
      options.opt = [options.opt] if typeof options.opt is 'string'
      # Build the docker command arguments
      cmd = ["volume create"]
      cmd.push "--driver #{options.driver}" if options.driver
      cmd.push "--label #{options.label.join ','}" if options.label
      cmd.push "--name #{options.name}" if options.name
      cmd.push "--opt #{options.opt.join ','}" if options.opt
      cmd = cmd.join ' '
      @system.execute
        if: options.name
        cmd: docker.wrap options, "volume inspect #{options.name}"
        code: 1
        code_skipped: 0
        shy: true
      @system.execute
        if: -> not options.name or @status -1
        cmd: docker.wrap options, cmd

## Modules Dependencies

    docker = require '@nikitajs/core/lib/misc/docker'
