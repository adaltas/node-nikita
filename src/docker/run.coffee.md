
# `nikita.docker.run(options, [callback])`

Run Docker Containers

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `container` (string)   
  Alias of name.
* `name` (string)   
   Assign a name to the container to run.
* `image` (string)   
  Name/ID of base image, required.
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `cmd` (string)   
  Overwrite the default ENTRYPOINT of the image, equivalent to 
  `--entrypoint docker parameter`
* `hostname` (string)   
  Hostname in the docker container.
* `port` ( 'int:int' | [] )   
  Port mapping.
* `volume` ( 'path:path' | [] )   
  Path mapping.
* `device` ('path' | [] )   
  Send host device(s) to container.
* `dns` (ip-address | [] )   
  Set custom DNS server(s).
* `dns_search` (ip-address | [] )   
  Set custom DNS search domain(s).
* `expose` ( int | string | [] )   
  Export port(s).
* `link` ( containerName | containerID | [] )   
  Link to other container(s).
* `label` (string | [] )   
  Set meta data on a container.
* `label_file` (path)   
  Read in a line delimited file of labels.
* `add_host` ('host:ip' | [] )   
  Add a custom host-to-IP mapping (host:ip).
* `cap_add` ( | [] )   
  Add Linux Capabilities.
* `cap_drop` ( | [] )   
  Drop Linux Capabilities.
* `blkio_weight` (int)   
  Block IO (relative weight), between 10 and 1000.
* `cgroup_parent`   
  Optional parent cgroup for the container.
* `cid_file` ( path )   
  Write the container ID to the file.
* `cpuset_cpus` (string)   
  CPUs in which to allow execution (ex: 0-3 0,1 ...).
* `entrypoint` ()   
  Overwrite the default ENTRYPOINT of the image.
* `ipc` ()   
  IPC namespace to use.
* `ulimit`  ( | [] )   
  Ulimit options.
* `volumes_from` (containerName | containerID | [] )   
  Mount volumes from the specified container(s).
* `detach` (boolean)   
  if true, run container in background.
* `env` ('VAR=value' | [] )   
  Environment variables for the container..
* `env_file` ( path | [] )   
  Read in a file of environment variables.
* `rm` (boolean)   
  Delete the container when it ends. True by default.
* `cwd` (path)   
  Working directory of container.
* `net` (string)   
  Set the Network mode for the container.
* `pid` (string)   
  PID namespace to use.
* `publish_all` (boolean)   
  Publish all exposed ports to random ports.
* `code`   (int|array)   
  Expected code(s) returned by the command, int or array of int, default to 0..
* `code_skipped`   
  Expected code(s) returned by the command if it has no effect, executed will
  not be incremented, int or array of int.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True unless contaianer was already running.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```javascript
nikita.docker({
  ssh: ssh
  name: 'myContainer'
  image: 'test-image'
  env: ["FOO=bar",]
  entrypoint: '/bin/true'
}, function(err, status, stdout, stderr){
  console.log( err ? err.message : 'Container state changed to running: ' + status);
})
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering Docker run", level: 'DEBUG', module: 'nikita/lib/docker/run'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      return callback Error 'Missing image' unless options.image?
      options.rm ?= true
      options.name ?= options.container
      options.log message: "Should specify a container name if rm is false", level: 'WARN', module: 'nikita/docker/run' unless options.name? or options.rm
      # Construct exec command
      cmd = 'run'
      # Classic options
      for opt, flag of { name: '--name', hostname: '-h', cpu_shares: '-c',
      cgroup_parent: '--cgroup-parent', cid_file: '--cidfile', blkio_weight: '--blkio-weight',
      cpuset_cpus: '--cpuset-cpus', entrypoint: '--entrypoint', ipc: '--ipc',
      log_driver: '--log-driver', memory: '-m', mac_address: '--mac-address',
      memory_swap: '--memory-swap', net: '--net', pid: '--pid', cwd: '-w'}
        cmd += " #{flag} #{options[opt]}" if options[opt]?
      cmd += ' -d' if options.detach # else ' -t'
      # Flag options
      for opt, flag of { rm: '--rm', publish_all: '-P', privileged: '--privileged', read_only: '--read-only' }
        cmd += " #{flag}" if options[opt]
      # Arrays Options
      for opt, flag of { port:'-p', volume: '-v', device: '--device', label: '-l',
      label_file: '--label-file', expose: '--expose', env: '-e', env_file: '--env-file',
      dns: '--dns', dns_search: '--dns-search', volumes_from: '--volumes-from',
      cap_add: '--cap-add', cap_drop: '--cap-drop', ulimit: '--ulimit', add_host: '--add-host' }
        if options[opt]?
          if typeof options[opt] is 'string' or typeof options[opt] is 'number'
            cmd += " #{flag} #{options[opt]}"
          else if Array.isArray options[opt]
            for p in options[opt]
              if typeof p in ['string', 'number']
                cmd += " #{flag} #{p}"
              else callback Error "Invalid parameter, '#{opt}' array should only contains string or number"
          else callback Error "Invalid parameter, '#{opt}' should be string, number or array"
      cmd += " #{options.image}"
      cmd += " #{options.cmd}" if options.cmd
      # need to delete the cmd options or it will be used in docker.exec
      delete options.cmd
      @system.execute
        if: options.name?
        cmd: docker.wrap options, "ps -a | grep '#{options.name}'"
        code_skipped: 1
        shy: true
      , (err, running) ->
        docker.callback arguments...
        options.log message: "Container already running. Skipping", level: 'INFO', module: 'nikita/docker/run' if running
      @system.execute
        cmd: docker.wrap options, cmd
        if: ->
          not options.name? or @status(-1) is false
      , (err, running) ->
        docker.callback arguments...
        options.log message: "Container now running", level: 'WARN', module: 'nikita/docker/run' if running
        callback arguments...

## Modules Dependencies

    docker = require '../misc/docker'
