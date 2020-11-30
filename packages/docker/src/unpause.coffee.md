
# `nikita.docker.unpause`

Unpause all processes within a container.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was unpaused.

## Example

```js
const {status} = await nikita.docker.unpause({
  container: 'toto'
})
console.info(`Container was unpaused: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'container':
          type: 'string'
          description: """
          Name/ID of the container
          """
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['container']

## Handler

    handler = ({config, tools: {find, log}}) ->
      log message: "Entering Docker unpause", level: 'DEBUG', module: 'nikita/lib/docker/unpause'
      # Validation
      throw Error 'Missing container parameter' unless config.container?
      @docker.tools.execute
        cmd: "unpause #{config.container}"

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
      schema: schema
