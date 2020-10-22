
# `nikita.docker.stop`

Stop a started container.

## Options


## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True unless container was already stopped.

## Example

```javascript
require('nikita')
.docker.stop({
  container: 'toto'
}, function(err, {status}){
  console.info( err ? err.message : 'Container state changed to stopped: ' + status);
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
        'timeout':
          type: 'integer'
          description: """
          Seconds to wait for stop before killing the container (Docker default
          is 10).
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
      log message: "Entering Docker stop", level: 'DEBUG', module: 'nikita/lib/docker/stop'
      # rm is false by default only if config.service is true
      {status} = await @docker.tools.status shy: true, config
      if status
      then log message: "Stopping container #{config.container}", level: 'INFO', module: 'nikita/lib/docker/stop'
      else log message: "Container already stopped #{config.container} (Skipping)", level: 'INFO', module: 'nikita/lib/docker/stop'
      @docker.tools.execute
        if: status
        cmd: [
          'stop'
          "-t #{config.timeout}" if config.timeout?
          "#{config.container}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
      schema: schema

## Dependencies

    docker = require './utils'
    util = require 'util'
