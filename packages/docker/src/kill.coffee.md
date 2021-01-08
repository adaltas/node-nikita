
# `nikita.docker.kill`

Send signal to containers using SIGKILL or a specified signal.
Note if container is not running , SIGKILL is not executed and
return status is UNMODIFIED. If container does not exist nor is running
SIGNAL is not sent.

## Output

* `err`   
  Error object if any.
* `status`   
  True if container was killed.

## Example

```js
const {status} = await nikita.docker.kill({
  container: 'toto',
  signal: 9
})
console.info(`Container was killed: ${status}`)
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
        'docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/docker'
        'signal':
          oneOf: [
            {type: 'integer'}
            {type: 'string'}
          ]
          description: """
          Use a specified signal. SIGKILL by default.
          """
      required: ['container']

## Handler

    handler = ({config}) ->
      {status} = await @docker.tools.execute
        command: "ps | egrep ' #{config.container}$' | grep 'Up'"
        code_skipped: 1
      await @docker.tools.execute
        if: -> status
        command: [
          'kill'
          "-s #{config.signal}" if config.signal?
          "#{config.container}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        schema: schema
