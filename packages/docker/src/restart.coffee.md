
# `nikita.docker.start`

Start stopped containers or restart (stop + starts) a started container.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True if container was restarted.  

## Example

```javascript
require('nikita')
.docker.restart({
  container: 'toto'
}, function(err, {status}){
  console.info( err ? err.message : 'Container restarted: ' + status);
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          type: 'string'
          description: """
          Name/ID of the container, required.
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

    handler = ({config, tools: {find, log}}) ->
      log message: "Entering Docker restart", level: 'DEBUG', module: 'nikita/lib/docker/restart'
      @docker.tools.execute
        cmd: [
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
