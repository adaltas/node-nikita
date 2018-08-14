
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

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering Docker unpause", level: 'DEBUG', module: 'nikita/lib/docker/unpause'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validation
      throw Error 'Missing container parameter' unless options.container?
      @system.execute
        cmd: docker.wrap options, "unpause #{options.container}"
      , -> docker.callback callback, arguments...

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
