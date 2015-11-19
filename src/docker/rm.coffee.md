
# `docker_rm(options, callback)`

Remove one or more containers. Containers need to be stopped to be deleted unless
force options is set.

## Options

*   `container` (string)
    Name/ID of the container. MANDATORY
*   `machine` (string)
    Name of the docker-machine. MANDATORY if docker-machine installed
*   `link` (boolean)
    Remove the specified link
*   `volumes` (boolean)
    Remove the volumes associated with the container
*   `force` (boolean)
    Force the removal of a running container (uses SIGKILL)

## Example

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters and madatory conditions
      return callback  Error 'Missing container parameter' unless options.container?
      cmd = ' rm '
      for opt in ['link', 'volumes', 'force']
        cmd += "-#{opt.charAt 0} " if options[opt]
      cmd += options.container
      docker.exec " ps | grep '#{options.container}' ", options, true, (err, executed, stdout, stderr) ->
        return callback err, executed, stdout, stderr if err
        if executed
          if options.force
            docker.exec cmd, options, false, (err, executed, stdout, stderr) ->
              callback err, executed, stdout, stderr
          else
            return callback Error 'Container must be stopped to be removed without force'
        else
          docker.exec " ps -a | grep '#{options.container}' ", options, true, (err, executed, stdout, stderr) ->
            return callback err, executed, stdout, stderr if err or !executed
            if executed
              docker.exec cmd, options, true, (err, executed, stdout, stderr) ->
                callback err, executed, stdout, stderr





## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
