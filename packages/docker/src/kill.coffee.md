
# `nikita.docker.kill`

Send signal to containers using SIGKILL or a specified signal.
Note if container is not running , SIGKILL is not executed and
return status is UNMODIFIED. If container does not exist nor is running
SIGNAL is not sent.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was killed.

## Example

```javascript
require('nikita')
.docker.kill({
  container: 'toto',
  signal: 9
}, function(err, status){  
  console.log( err ? err.message : 'Container killed: ' + status);
})
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
        'signal':
          oneOf: [
            {type: 'integer'}
            {type: 'string'}
          ]
          description: """
          Use a specified signal. SIGKILL by default.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['container']

## Handler

    handler = ({config, log, tools: {find}}) ->
      log message: "Entering Docker kill", level: 'DEBUG', module: 'nikita/lib/docker/kill'
      {status} = await @docker.tools.execute
        cmd: "ps | egrep ' #{config.container}$' | grep 'Up'"
        code_skipped: 1
      @docker.tools.execute
        if: -> status
        cmd: [
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
