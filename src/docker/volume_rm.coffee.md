
# `nikita.volume_rm(options, [callback])`

Remove a volume. 

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `container` (string|array). __Mandatory__   
    Name or Id of the container.   
*   `machine` (string)   
    Name of the docker-machine. __Mandatory__ if using docker-machine.   
*   `name` (string)   
    Specify volume name.   

## Example

```javascript
nikita.docker.volume_rm({
  name: 'my_volume'
}, function(err, removed){
  console.log(err or 'Status'+removed);
})
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker volume_rm", level: 'DEBUG', module: 'nikita/lib/docker/volume_rm'
      # Validate parameters
      throw Error "Missing required option name" unless options.name
      @system.execute
        cmd: docker.wrap options, "volume rm #{options.name}"
        code: 0
        code_skipped: 1

## Modules Dependencies

    docker = require '../misc/docker'
