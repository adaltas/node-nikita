
# `nikita.docker.inspect`

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

Inspect a single container.

```js
const {info} = await nikita.docker.inspect({
  name: 'my_container'
})
console.info(`Container id is ${info.Id}`)
```

Inspect multiple containers.

```js
const {info} = await nikita.docker.inspect({
  name: 'my_container'
})
info.map( (container) =>
  console.info(`Container id is ${container.Id}`)
)
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          oneOf: [
            type: 'string'
          ,
            type: 'array'
            items: type: 'string'
          ]
          description: """
          Name/ID of the container (array of containers not yet implemented).
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['container']

## Handler

    handler = ({args, config}) ->
      isCointainerArray = Array.isArray arg?.container for arg in args
      # Ensure target container exists
      {status: exists} = await @docker.tools.execute
        command: "ps -a | egrep ' #{config.container}$'"
        code_skipped: 1
      throw Error "Container #{JSON.stringify config.container} does not exists" unless exists
      # Get information
      {stdout: info} = await @docker.tools.execute
        command: [
          'inspect'
          "#{config.container}"
        ].join ' '
      info = JSON.parse info
      info: if isCointainerArray then info else info[0]

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        schema: schema
