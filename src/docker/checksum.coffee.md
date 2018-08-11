
# `nikita.docker.build`

Return the checksum of repository:tag, if it exists. Function not native to docker.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `cwd` (string)   
  change the working directory for the build.
* `image` (string)   
  Name of the image, required.
* `repository` (string)   
  Alias of image.
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `tag` (string)   
  Tag of the image, default to latest.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if command was executed.
* `checksum`   
  Image cheksum if it exist, undefined otherwise.

## Source Code

    module.exports = (options, callback) ->
      @log message: "Entering Docker checksum", level: 'DEBUG', module: 'nikita/lib/docker/checksum'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validation
      options.image ?= options.repository
      return callback Error 'Missing repository parameter' unless options.image?
      options.tag ?= 'latest'
      # Run `docker images` with the following options:
      # - `--no-trunc`: display full checksum
      # - `--quiet`: discard headers
      cmd = "images --no-trunc --quiet #{options.image}:#{options.tag}"
      @log message: "Getting image checksum :#{options.image}", level: 'INFO', module: 'nikita/lib/docker/checksum'
      @system.execute
        cmd: docker.wrap options, cmd
      , (err, {status, stdout, stderr}) ->
        checksum = if stdout is '' then undefined else stdout.toString().trim()
        @log message: "Image checksum for #{options.image}: #{checksum}", level: 'INFO', module: 'nikita/lib/docker/checksum' if status
        return callback err, status: status, checksum: checksum


## Modules Dependencies

    docker = require '../misc/docker'
