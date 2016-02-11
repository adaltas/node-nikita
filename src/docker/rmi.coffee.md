
# `docker_rmi(options, callback)`

Remove images. All container using image should be stopped to delete it unless
force options is set.

## Options

*   `image` (string)   
    Name of the image. MANDATORY   
*   `machine` (string)   
    Name of the docker-machine. MANDATORY if docker-machine installed   
*   `no_prune` (boolean)   
    Do not delete untagged parents   

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters and madatory conditions
      return callback  Error 'Missing image parameter' unless options.image?
      cmd = 'rmi'
      for opt in ['force', 'no_prune']
        cmd += " --#{opt.replace '_', '-'}" if options[opt]?
      cmd += " #{options.image}"
      cmd += ":#{options.tag}" if options.tag?
      list_images = 'images'
      list_images += " | grep '#{options.image} '"
      list_images += " | grep ' #{options.tag} '" if options.tag?
      @execute
        cmd: docker.wrap options, list_images
        code_skipped: 1
      @execute
        cmd: docker.wrap options, cmd
        if: -> @status -1
      .then -> docker.callback callback, arguments...

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
