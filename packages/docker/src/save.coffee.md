
# `nikita.docker.save`

Save Docker images.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `image` (string)   
  Name/ID of base image, required.
* `tag` (string)   
  Tag of the image.
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `output` (string).   
  TAR archive output path, required.
* `target` (string).   
  Shortcut for "output" option, required.
* `code` (int | array)   
  Expected code(s) returned by the command, int or array of int, default to 0.
* `code_skipped`   
  Expected code(s) returned by the command if it has no effect, executed will
  not be incremented, int or array of int.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was saved.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```javascript
nikita.docker({
  ssh: ssh
  output: 'test-image.tar'
  image: 'test-image'
  compression: 'gzip'
  entrypoint: '/bin/true'
}, function(err, {status}){
  console.log( err ? err.message : 'Container saved: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering Docker save", level: 'DEBUG', module: 'nikita/lib/docker/save'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters
      throw Error 'Missing image parameter' unless options.image?
      options.output ?= options.target
      throw Error 'Missing output parameter' unless options.output?
      # Saves image to local tmp path, than copy it
      cmd = "save -o #{options.output} #{options.image}"
      cmd += ":#{options.tag}" if options.tag?
      @log message: "Extracting image #{options.output} to file:#{options.image}", level: 'INFO', module: 'nikita/lib/docker/save'
      @system.execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    util = require 'util'  
    docker = require '@nikita/core/lib/misc/docker'
