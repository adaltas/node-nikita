
# `nikita.volume_create(options, [callback])`

Create a volume. 

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `driver` (string)   
    Specify volume driver name.   
*   `label` (string|array)   
    Set metadata for a volume.   
*   `machine` (string)   
    Name of the docker-machine. __Mandatory__ if using docker-machine   
*   `name` (string)   
    Specify volume name.   
*   `opt` (string|array)   
    Set driver specific options.

## Example

```javascript
nikita.docker.pause({
  name: 'my_volume'
}, function(err, created){
  console.log(err or 'Status: '+created);
})
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker volume_create", level: 'DEBUG', module: 'nikita/lib/docker/volume_create'
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
      , (err, status, stdout) ->
        console.log 'STDOUT: '+stdout

## Modules Dependencies

    docker = require '../misc/docker'
