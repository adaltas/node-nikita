
# `nikita.docker.rm`

Remove one or more containers. Containers need to be stopped to be deleted unless
force options is set.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `container` (string)   
  Name/ID of the container, required.
* `machine` (string)   
  Name of the docker-machine, required if docker-machine installed.
* `link` (boolean)   
  Remove the specified link.
* `volumes` (boolean)   
  Remove the volumes associated with the container.
* `force` (boolean)   
  Force the removal of a running container (uses SIGKILL).

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was removed.

## Example Code

```javascript
require('nikita')
.docker.rm({
  container: 'toto'
}, function(err, status){
  console.log( err ? err.message : 'Container removed: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering Docker rm", level: 'DEBUG', module: 'nikita/lib/docker/rm'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters and madatory conditions
      return callback Error 'Missing container parameter' unless options.container?
      cmd = for opt in ['link', 'volumes', 'force']
        "-#{opt.charAt 0}" if options[opt]
      cmd = "rm #{cmd.join ' '} #{options.container}"
      @system.execute
        cmd: docker.wrap options, "ps | grep '#{options.container}'"
        code_skipped: 1
      , (err, {status}) =>
        throw Error 'Container must be stopped to be removed without force', null if status and not options.force
      @system.execute
        cmd: docker.wrap options, "ps -a | grep '#{options.container}'"
        code_skipped: 1
      , docker.callback
      @system.execute
        cmd: docker.wrap options, cmd
        if: -> @status -1
      , docker.callback

## Modules Dependencies

    docker = require '@nikita/core/lib/misc/docker'
