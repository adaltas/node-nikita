
# `nikita.docker.restart`

Start stopped containers or restart (stop + starts) a started container.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True if container was restarted.  

## Example

```js
const {status} = await nikita.docker.restart({
  container: 'toto'
})
console.info(`Container was started or restarted: ${status}`)
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
        'timeout':
          type: 'integer'
          description: """
          Seconds to wait for stop before killing it.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['container']

## Handler

    handler = ({config}) ->
      await @docker.tools.execute
        command: [
          'restart'
          "-t #{config.timeout}" if config.timeout?
          "#{config.container}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        schema: schema
