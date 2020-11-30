
# `nikita.docker.run`

Run Docker Containers

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

```js
const {status} = await nikita.docker.run({
  ssh: ssh
  name: 'myContainer'
  image: 'test-image'
  env: ["FOO=bar",]
  entrypoint: '/bin/true'
})
console.info(`Container was run: ${status}`)
```

## Hooks

    on_action = ({config}) ->
      # throw Error 'Property "container" no longer exists' if config.container
      # config.name = config.container if not config.name? and config.container?
      config.name ?= config.container
      config.expose = parseInt config.expose if typeof config.expose is 'string'

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          type: 'string'
          description: """
          Alias of name.
          """
        'name':
          type: 'string'
          description: """
          Assign a name to the container to run.
          """
        'image':
          type: 'string'
          description: """
          Name/ID of base image.
          """
        'entrypoint':
          type: 'string'
          description: """
          Overwrite the default ENTRYPOINT of the image, equivalent to
          `--entrypoint docker parameter`
          """
        'hostname':
          type: 'string'
          description: """
          Hostname in the docker container.
          """
        'port':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Port mapping in the form of `int:int`.
          """
        'volume':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Volume mapping, in the form of `path:path`.
          """
        'device':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Send host device(s) to container.
          """
        'dns':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Set custom DNS server(s).
          """
        'dns_search':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Set custom DNS search domain(s).
          """
        'expose':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Export port(s).
          """
        'link':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Link to other container(s) in the form of a container name or a
          container ID.
          """
        'label':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Set meta data on a container.
          """
        'label_file':
          type: 'string'
          description: """
          Path to read in a line delimited file of labels.
          """
        'add_host':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Add a custom host-to-IP mapping (host:ip) in the form of `host:ip`.
          """
        'cap_add':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Add Linux Capabilities.
          """
        'cap_drop':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Drop Linux Capabilities.
          """
        'blkio_weight':
          type: 'integer'
          description: """
          Block IO (relative weight), between 10 and 1000.
          """
        'cgroup_parent':
          type: 'string'
          description: """
          Optional parent cgroup for the container.
          """
        'cid_file':
          type: 'string'
          description: """
          Write the container ID to the file.
          """
        'cpuset_cpus':
          type: 'string'
          description: """
          CPUs in which to allow execution (ex: 0-3 0,1 ...).
          """
        'ipc':
          type: 'string'
          description: """
          IPC namespace to use.
          """
        'ulimit':
          oneOf: [
            {type: 'string'}
            {type: 'integer'}
            {type: 'array', items: oneOf: [ {type: 'string'}, {type: 'integer'} ]}
          ]
          description: """
          Ulimit options.
          """
        'volumes_from':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Mount volumes from the specified container(s).
          """
        'detach':
          type: 'boolean'
          description: """
          if true, run container in background.
          """
        'env':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Environment variables for the container in the form of `VAR=value`.
          """
        'env_file':
          oneOf: [
            {type: 'string'}
            {type: 'array', items: type: 'string'}
          ]
          description: """
          Read in a file of environment variables.
          """
        'rm':
          type: 'boolean'
          default: true
          description: """
          Delete the container when it ends. True by default.
          """
        'cwd':
          type: 'string'
          description: """
          Working directory of container.
          """
        'net':
          type: 'string'
          description: """
          Set the Network mode for the container.
          """
        'pid':
          type: 'string'
          description: """
          PID namespace to use.
          """
        'publish_all':
          type: 'boolean'
          description: """
          Publish all exposed ports to random ports.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['image']

## Handler

    handler = ({config, tools: {find, log}}) ->
      log message: "Entering Docker run", level: 'DEBUG', module: 'nikita/lib/docker/run'
      # Validate parameters
      log message: "Should specify a container name if rm is false", level: 'WARN', module: 'nikita/docker/run' unless config.name? or config.rm
      # Construct exec command
      cmd = 'run'
      # Classic config
      for opt, flag of { name: '--name', hostname: '-h', cpu_shares: '-c',
      cgroup_parent: '--cgroup-parent', cid_file: '--cidfile', blkio_weight: '--blkio-weight',
      cpuset_cpus: '--cpuset-cpus', entrypoint: '--entrypoint', ipc: '--ipc',
      log_driver: '--log-driver', memory: '-m', mac_address: '--mac-address',
      memory_swap: '--memory-swap', net: '--net', pid: '--pid', cwd: '-w'}
        cmd += " #{flag} #{config[opt]}" if config[opt]?
      cmd += ' -d' if config.detach # else ' -t'
      # Flag config
      for opt, flag of { rm: '--rm', publish_all: '-P', privileged: '--privileged', read_only: '--read-only' }
        cmd += " #{flag}" if config[opt]
      # Arrays config
      for opt, flag of { port:'-p', volume: '-v', device: '--device', label: '-l',
      label_file: '--label-file', expose: '--expose', env: '-e', env_file: '--env-file',
      dns: '--dns', dns_search: '--dns-search', volumes_from: '--volumes-from',
      cap_add: '--cap-add', cap_drop: '--cap-drop', ulimit: '--ulimit', add_host: '--add-host' }
        if config[opt]?
          if typeof config[opt] is 'string' or typeof config[opt] is 'number'
            cmd += " #{flag} #{config[opt]}"
          else if Array.isArray config[opt]
            for p in config[opt]
              if typeof p in ['string', 'number']
                cmd += " #{flag} #{p}"
              else callback Error "Invalid parameter, '#{opt}' array should only contains string or number"
          else callback Error "Invalid parameter, '#{opt}' should be string, number or array"
      cmd += " #{config.image}"
      cmd += " #{config.cmd}" if config.cmd
      # need to delete the cmd config or it will be used in docker.exec
      # delete config.cmd
      {status} = await @docker.tools.execute
        if: config.name?
        cmd: "ps -a | egrep ' #{config.name}$'"
        code_skipped: 1
        shy: true
      log message: "Container already running. Skipping", level: 'INFO', module: 'nikita/docker/run' if status
      result = await @docker.tools.execute
        cmd: cmd
        if: -> not config.name? or status is false
      log message: "Container now running", level: 'WARN', module: 'nikita/docker/run' if result.status
      result

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        global: 'docker'
      schema: schema
