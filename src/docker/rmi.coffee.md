
# `docker_rmi(options, callback)`

Remove images. All container using image should be stopped to delete it unless
force options is set.

## Options

*   `image` (string)
    Name of the image. MANDATORY
*   `machine` (string)
    Name of the docker-machine. MANDATORY if docker-machine installed
*   `no_prune` (boolean)
    Remove the volumes associated with the container
*   `force` (boolean)
    Force the removal of a running container (uses SIGKILL)

## Example

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters and madatory conditions
      return callback  Error 'Missing image parameter' unless options.image?
      cmd = ' rmi '
      for opt in ['force', 'no_prune']
        cmd += "--#{opt.replace '_', '-'} " if options[opt]?
      cmd += options.image
      parts = options.image.split(':')
      repository = parts[0] ?= ''
      tag = parts[1] ?= ''
      docker.exec " images | grep '#{repository}' | grep '#{tag}'", options, true, (err, exists,  stdout, stderr) ->
        return callback err, exists if (err or !exists)
        docker.exec cmd, options, null
          , (err, executed, stdout, stderr) ->
            callback err, executed, stdout, stderr



## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
