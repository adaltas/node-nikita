
# `nikita.docker.service(options, [callback])`

Run a container in a service mode. This module is just a wrapper for docker.run
with correct options.

Indeed, in a service mode, the container must be detached and NOT removed by default
after execution. 

## Options

See `docker.run` for list of options.

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker service", level: 'DEBUG', module: 'nikita/lib/docker/service'
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      options.detach ?= true
      options.rm ?= false
      throw Error 'Missing container name' unless options.name? or options.container?
      @docker.run options
