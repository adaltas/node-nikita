
# `nikita.docker.wait`

Block until a container stops.

## Output

* `err`   
  Error object if any.   
* `status`   
  True unless container was already stopped.

## Example

```js
const {status} = await nikita.docker.wait({
  container: 'toto'
})
console.info(`Did we really had to wait: ${status}`)
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
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      require: ['container']

## Handler

    handler = ({config}) ->
      # Old implementation was `wait {container} | read r; return $r`
      await @docker.tools.execute "wait #{config.container}"

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        schema: schema
