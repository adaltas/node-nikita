
# `docker_rmi(options, callback)`

Remove images. All container using image should be stopped to delete it unless
force options is set.

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `image` (string)   
    Name of the image. MANDATORY   
*   `machine` (string)   
    Name of the docker-machine. MANDATORY if docker-machine installed   
*   `no_prune` (boolean)   
    Do not delete untagged parents   

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker rmi", level: 'DEBUG', module: 'mecano/lib/docker/rmi'
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
      @execute
        cmd: docker.wrap options, cmd_images
        code_skipped: 1
      , docker.callback
      @execute
        cmd: docker.wrap options, cmd_rmi
        if: -> @status -1
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
