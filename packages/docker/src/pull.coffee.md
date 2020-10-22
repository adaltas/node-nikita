
# `nikita.docker.pull`

Pull a container.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was pulled.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

1- builds an image from dockerfile without any resourcess

```javascript
require('nikita')
.docker.pull({
  tag: 'postgresql'
}, function(err, {status}){
  console.log( err ? err.message : 'Container pulled: ' + status);
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'tag':
          type: 'string'
          description: """
          Name of the tag to pull.
          """
        'version':
          type: 'string'
          description: """
          Version of the tag to control. Default to `latest`.
          """
        'all':
          type: 'boolean'
          description: """
          Download all tagged images in the repository.  Default to false.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'

## Handler

    handler = ({config, log, tools: {find}}) ->
      log message: "Entering Docker pull", level: 'DEBUG', module: 'nikita/lib/docker/pull'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Validate parameters
      version = config.version or config.tag.split(':')[1] or 'latest'
      delete config.version # present in misc.docker.config, will probably disappear at some point
      config.all ?= false
      throw Error 'Missing Tag Name' unless config.tag?
      # rm is false by default only if config.service is true
      cmd = 'pull'
      cmd += if config.all then  " -a #{config.tag}" else " #{config.tag}:#{version}"
      {status} = await @docker.tools.execute
        cmd: [
          'images'
          "| grep '#{config.tag}'"
          "| grep '#{version}'" unless config.all
        ].join ' '
        code_skipped: 1
      @docker.tools.execute
        unless: status
        cmd: cmd

## Exports

    module.exports =
      handler: handler
      schema: schema
