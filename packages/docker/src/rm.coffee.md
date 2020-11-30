
# `nikita.docker.rm`

Remove one or more containers. Containers need to be stopped to be deleted unless
force options is set.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was removed.

## Example Code

```js
const {status} = await nikita.docker.rm({
  container: 'toto'
})
console.info(`Container was removed: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          type: 'string'
          description: """
          Name/ID of the container.
          """
        'link':
          type: 'boolean'
          description: """
          Remove the specified link.
          """
        'volumes':
          type: 'boolean'
          description: """
          Remove the volumes associated with the container.
          """
        'force':
          type: 'boolean'
          description: """
          Force the removal of a running container (uses SIGKILL).
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['container']

## Handler

    handler = ({config, tools: {find, log}}) ->
      log message: "Entering Docker rm", level: 'DEBUG', module: 'nikita/lib/docker/rm'
      # cmd = for opt in ['link', 'volumes', 'force']
      #   "-#{opt.charAt 0}" if config[opt]
      # cmd = "rm #{cmd.join ' '} #{config.container}"
      {status} = await @docker.tools.execute
        cmd: "ps | egrep ' #{config.container}$'"
        code_skipped: 1
      throw Error 'Container must be stopped to be removed without force' if status and not config.force
      {status} = await @docker.tools.execute
        cmd: "ps -a | egrep ' #{config.container}$'"
        code_skipped: 1
      @docker.tools.execute
        cmd: [
          'rm'
          ...( ['link', 'volumes', 'force']
            .filter (opt) -> config[opt]
            .map (opt) -> "-#{opt.charAt 0}"
          )
          config.container
        ].join ' '
        if: -> status

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
      schema: schema

## Dependencies

    docker = require './utils'
