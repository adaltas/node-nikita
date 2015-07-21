
# `docker_rm(options, callback)`

Remove one or more containers. Containers need to be stopped to be deleted unless
force options is set.

## Options

*   `name` (string)
    Name of the container. MANDATORY
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
      return callback  Error 'Missing name parameter' unless options.name?
      docker.get_provider options, (err,  provider) =>
        return callback err if err
        options.provider = provider
        cmd = docker.prepare_cmd provider, options.machine
        cmd += 'docker rm'
        for opt in ['link', 'volumes', 'force']
          cmd += " --#{opt}=#{options[opt]}" if options[opt]?
        cmd += " #{options.name}"
        @execute
          cmd: cmd
        .then callback
