
# `mecano.docker.compose(options, [callback])`

Create and start containers according to a docker-compose file
`mecano.docker.compose` is an alias to `mecano.docker.compose.up`

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `machine` (string)   
    Name of the docker-machine. __Mandatory__ if using docker-machine   
*   `content` (string)   
    The content of the docker-compose.yml to write if not exist.   
*   `eof` (string)   
    Inherited from mecano.file use when writing docker-compose.yml file.   
*   `backup` (string)   
    Inherited from mecano.file use when writing docker-compose.yml file.   
*   `detached` (boolean)   
    Run Containers in detached mode. Default to true   
*   `force` (boolean)   
     Force to re-create the containers if the config and image have not changed   
    Default to false   
*   `services` (string|array)
    Specify specific services to create.
*   `target` (string)   
    The docker-compose.yml absolute's file's path. Mandatory if no content is 
    specified.   
*   `code` (int|array)   
    Expected code(s) returned by the command, int or array of int, default to 0.   
*   `code_skipped`   
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

    module.exports = (options) ->
      options.log message: "Entering Docker Compose", level: 'DEBUG', module: 'mecano/lib/docker/compose/up'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      throw Error 'Missing docker-compose content or target' if not options.target? and not options.content?
      options.target ?= "/tmp/docker_compose_#{Date.now()}/docker-compose.yml" if options.content and not options.target?
      options.detached ?= true
      options.force ?= false
      options.recreate ?= false
      options.services ?= []
      options.services = [options.services] if not Array.isArray options.services
      services = options.services.join ' '
      # Construct exec command
      cmd = " --file #{options.target}"
      cmd_ps = "#{cmd} ps -q | xargs docker inspect"
      cmd_up = "#{cmd} up"
      cmd_up += ' -d ' if options.detached
      cmd_up += ' --force-recreate ' if options.force
      cmd_up +=  " #{services}"
      source_dir = "#{path.dirname options.target}"
      options.eof ?= true
      options.backup ?= false
      options.compose = true
      @file.yaml 
        if: options.content?
        eof: options.eof
        backup: options.backup
        target: options.target
        content: options.content
      @call (_, callback) ->
        start = true
        @execute
          cmd: docker.wrap options, cmd_ps
          cwd: options.cwd
          uid: options.uid
          code_skipped: 123 # Container not created
          stdout_log: false
        , (err, status, stdout, stderr) ->
          throw err if err
          return start = true unless status
          containers = JSON.parse stdout
          start = containers.some (container) -> not container.State.Running
          options.log "Docker created, need start" if start
        @then -> callback null, start
      @execute 
        if: -> options.force or @status()
        cwd: source_dir
        cmd: docker.wrap options, cmd_up
      , docker.callback
      
## Modules Dependencies

    docker = require '../../misc/docker'
    path = require 'path'
