
# `nikita.docker.compose`

Create and start containers according to a docker-compose file
`nikita.docker.compose` is an alias to `nikita.docker.compose.up`

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `content` (string)   
  The content of the docker-compose.yml to write if not exist.
* `eof` (string)   
  Inherited from nikita.file use when writing docker-compose.yml file.
* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `detached` (boolean)   
  Run Containers in detached mode. Default to true.
* `force` (boolean)   
  Force to re-create the containers if the config and image have not changed
  Default to false
* `services` (string|array)
  Specify specific services to create.
* `target` (string)   
  The docker-compose.yml absolute's file's path, required if no content is 
  specified.
* `code` (int|array)   
  Expected code(s) returned by the command, int or array of int, default to 0.
* `code_skipped`   
  Expected code(s) returned by the command if it has no effect, executed will
  not be incremented, int or array of int.

## Callback parameters

*   `err`   
    Error object if any.   
*   `executed`   
    if command was executed   
*   `stdout`   
    Stdout value(s) unless `stdout` option is provided.   
*   `stderr`   
    Stderr value(s) unless `stderr` option is provided.   

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering Docker Compose", level: 'DEBUG', module: 'nikita/lib/docker/compose/up'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters
      throw Error 'Missing docker-compose content or target' if not options.target? and not options.content?
      if options.content and not options.target?
        options.target ?= "/tmp/nikita_docker_compose_#{Date.now()}/docker-compose.yml"
        clean_target = true
      options.detached ?= true
      options.force ?= false
      options.recreate ?= false
      options.services ?= []
      options.services = [options.services] if not Array.isArray options.services
      services = options.services.join ' '
      # Construct exec command
      cmd = " --file #{options.target}"
      cmd_ps = "#{cmd} ps -q | xargs docker #{docker.opts options} inspect"
      cmd_up = "#{cmd} up"
      cmd_up += ' -d ' if options.detached
      cmd_up += ' --force-recreate ' if options.force
      cmd_up +=  " #{services}"
      source_dir = "#{path.dirname options.target}"
      options.eof ?= true
      options.backup ?= false
      options.compose = true
      @call ->
        @file.yaml
          if: options.content?
          eof: options.eof
          backup: options.backup
          target: options.target
          content: options.content
      @call (_, callback) ->
        @system.execute
          cmd: docker.wrap options, cmd_ps
          cwd: options.cwd
          uid: options.uid
          code_skipped: 123
          stdout_log: false
        , (err, {status, stdout}) ->
          return callback err if err
          return callback null, true unless status
          containers = JSON.parse stdout
          status = containers.some (container) -> not container.State.Running
          @log "Docker created, need start" if status
          callback null, status
      @system.execute
        if: -> options.force or @status()
        cwd: source_dir
        uid: options.uid
        cmd: docker.wrap options, cmd_up
      , docker.callback
      @system.remove
        if: clean_target
        target: options.target
        always: true # Not yet implemented

## Modules Dependencies

    docker = require '@nikitajs/core/lib/misc/docker'
    path = require 'path'
