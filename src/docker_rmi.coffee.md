
# `docker_rm(options, callback)`

Remove one or more containers. Containers need to be stopped to be deleted unless
force options is set.

## Options

*   `name` (string)
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
      return callback  Error 'Missing name parameter' unless options.name?
      docker.get_provider options, (err,  provider) =>
        return callback err if err
        options.provider = provider
        cmd = docker.prepare_cmd provider, options.machine
        cmd += 'docker rmi'
        for opt in ['force', 'no_prune']
          cmd += " --#{opt.replace '_', '-'}" if options[opt]?
        cmd += " #{options.name}"
        @execute
          log: options.log
          cmd: cmd
        .then callback
