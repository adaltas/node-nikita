
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

```js
const {status} = await nikita.docker.pull({
  tag: 'postgresql'
})
console.info(`Image was pulled: ${status}`)
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
          default: false
          description: """
          Download all tagged images in the repository.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'

## Handler

    handler = ({config, tools: {log}}) ->
      log message: "Entering Docker pull", level: 'DEBUG', module: 'nikita/lib/docker/pull'
      # Validate parameters
      version = config.version or config.tag.split(':')[1] or 'latest'
      delete config.version # present in misc.docker.config, will probably disappear at some point
      throw Error 'Missing Tag Name' unless config.tag?
      {status} = await @docker.tools.execute
        command: [
          'images'
          "| grep '#{config.tag}'"
          "| grep '#{version}'" unless config.all
        ].join ' '
        code_skipped: 1
      await @docker.tools.execute
        unless: status
        command: [
          'pull'
          if config.all
          then "-a #{config.tag}"
          else "#{config.tag}:#{version}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        schema: schema
