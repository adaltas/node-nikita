
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
      docker.get_provider options, (err,  provider) =>
        return callback err if err
        options.provider = provider
        cmd = docker.prepare_cmd provider, options.machine
        return callback cmd if util.isError cmd
        cmd += 'docker rmi '
        for opt in ['force', 'no_prune']
          cmd += "--#{opt.replace '_', '-'} " if options[opt]?
        cmd += options.image
        exec_opts =
          cmd: cmd
        for k in ['ssh','log', 'stdout','stderr','cwd','code','code_skipped']
          exec_opts[k] = options[k] if options[k]?
        @execute exec_opts, (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr

## Modules Dependencies

    docker = require './commons'
    util = require 'util'
