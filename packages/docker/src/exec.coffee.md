
# `nikita.docker.exec`

Run a command in a running container

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True if command was executed in container.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.   
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.   

## Example

```js
const {status} = await nikita.docker.exec({
  container: 'myContainer',
  cmd: '/bin/bash -c "echo toto"'
})
console.info(`Command was executed: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          type: 'string'
          description: """
          Name/ID of the container
          """
        'code_skipped':
          oneOf: [
            {type: 'integer'}
            {type: 'array', items: type: 'integer'}
          ]
          description: """
          The exit code(s) to skip.
          """
        'service':
          type: 'boolean'
          default: false
          description: """
          If true, run container as a service, else run as a command, true by
          default.
          """
        'uid':
          oneOf: [
            {type: 'integer'}
            {type: 'string'}
          ]
          description: """
          Username or uid.
          """
        'gid':
          oneOf: [
            {type: 'integer'}
            {type: 'string'}
          ]
          description: """
          Groupname or gid.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['container', 'cmd']

## Handler

    handler = ({config, tools: {find, log}}) ->
      log message: "Entering Docker exec", level: 'DEBUG', module: 'nikita/lib/docker/exec'
      config.service ?= false
      # Construct exec command
      cmd = 'exec'
      if config.uid?
        cmd += " -u #{config.uid}"
        cmd += ":#{config.gid}" if config.gid?
      else if config.gid?
        log message: 'config.gid ignored unless config.uid is provided', level: 'WARN', module: 'nikita/lib/docker/exec'
      cmd += " #{config.container} #{config.cmd}"
      delete config.cmd
      @docker.tools.execute
        cmd: cmd
        code_skipped: config.code_skipped

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
      schema: schema
