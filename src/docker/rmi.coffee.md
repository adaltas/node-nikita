
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


## Source Code

    module.exports = (options, callback) ->
      # Validate parameters and madatory conditions
      return callback  Error 'Missing image parameter' unless options.image?
      cmd = ' rmi '
      for opt in ['force', 'no_prune']
        cmd += "--#{opt.replace '_', '-'} " if options[opt]?
      cmd += options.image
      parts = options.image.split(':')
      repository = parts[0]
      tag = parts[1] ?= ''
      list_images = " images "
      list_images += "| grep '#{repository}' " if repository.length
      list_images += "| grep '#{tag}' " if tag.length
      @execute
        cmd: docker.wrap options, list_images
        code_skipped: 1
      @execute
        cmd: docker.wrap options, cmd
        if: -> @status -1
      .then callback




## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
