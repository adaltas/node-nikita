
# `nikita.docker.status`

Return true if container is running. This function is not native to docker. 

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `container` (string|array)   
  Name or Id of the container, required.
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container is running.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```javascript
nikita.docker({
  ssh: ssh
  target: 'test-image.tar'
  image: 'test-image'
  compression: 'gzip'
  entrypoint: '/bin/true'
}, function(err, status, stdout, stderr){
  console.log( err ? err.message : 'Container running: ' + status);
})
```

## Source Code

    module.exports = (options) ->
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validation
      throw Error 'Missing container parameter' unless options.container?
      # Construct exec command
      cmd = "ps | grep '#{options.container}'"
      @system.execute
        cmd: docker.wrap options, cmd
        code_skipped: 1
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
