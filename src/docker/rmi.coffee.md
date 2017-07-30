
# `nikita.docker_rmi(options, [callback])`

Remove images. All container using image should be stopped to delete it unless
force options is set.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `image` (string)   
  Name of the image, required.
* `machine` (string)   
  Name of the docker-machine, required if docker-machine installed.
* `no_prune` (boolean)   
  Do not delete untagged parents.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if image was removed.

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker rmi", level: 'DEBUG', module: 'nikita/lib/docker/rmi'
      # Validate parameters and madatory conditions
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      throw Error 'Missing image parameter' unless options.image?
      cmd_images = 'images'
      cmd_images += " | grep '#{options.image} '"
      cmd_images += " | grep ' #{options.tag} '" if options.tag?
      cmd_rmi = 'rmi'
      for opt in ['force', 'no_prune']
        cmd_rmi += " --#{opt.replace '_', '-'}" if options[opt]?
      cmd_rmi += " #{options.image}"
      cmd_rmi += ":#{options.tag}" if options.tag?
      @system.execute
        cmd: docker.wrap options, cmd_images
        code_skipped: 1
      , docker.callback
      @system.execute
        cmd: docker.wrap options, cmd_rmi
        if: -> @status -1
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
