
# `nikita.docker.save`

Save Docker images.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was saved.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```javascript
nikita.docker({
  ssh: ssh
  output: 'test-image.tar'
  image: 'test-image'
  compression: 'gzip'
  entrypoint: '/bin/true'
}, function(err, {status}){
  console.log( err ? err.message : 'Container saved: ' + status);
})
```

## Hooks

    on_action = ({config}) ->
      config.output ?= config.target

## Schema

    schema =
      type: 'object'
      properties:
        'image':
          type: 'string'
          description: """
          Name/ID of base image, required.
          """
        'tag':
          type: 'string'
          description: """
          Tag of the image.
          """  
        'output':
          type: 'string'
          description: """
          TAR archive output path, required.
          """
        'target':
          type: 'string'
          description: """
          Shortcut for "output" option, required.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['image', 'output']

## Handler

    handler = ({config, log, tools: {find}}) ->
      log message: "Entering Docker save", level: 'DEBUG', module: 'nikita/lib/docker/save'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Saves image to local tmp path, than copy it
      log message: "Extracting image #{config.output} to file:#{config.image}", level: 'INFO', module: 'nikita/lib/docker/save'
      @docker.tools.execute
        cmd: [
          "save -o #{config.output} #{config.image}"
          ":#{config.tag}" if config.tag?
        ].join ''

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema
