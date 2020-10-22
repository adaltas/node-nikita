
# `nikita.docker.restart`

Start a container.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True unless container was already started.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

1- builds an image from dockerfile without any resourcess

```javascript
require('nikita')
.docker.start({
  container: 'toto',
  attach: true
}, function(err, is_true, stdout, stderr){
  console.log( err ? err.message : 'Container state changed to started: ' + status);
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'attach':
          type: 'boolean'
          default: false
          description: """
          Attach STDOUT/STDERR.
          """
        'container':
          type: 'string'
          description: """
          Name/ID of the container, required.
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
      log message: "Entering Docker start", level: 'DEBUG', module: 'nikita/lib/docker/start'
      {status} = await @docker.tools.status shy: true, config
      if status
      then log message: "Container already started #{config.container} (Skipping)", level: 'INFO', module: 'nikita/lib/docker/start'
      else log message: "Starting container #{config.container}", level: 'INFO', module: 'nikita/lib/docker/start'
      @docker.tools.execute
        unless: status
        cmd: [
          'start'
          '-a' if config.attach
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
