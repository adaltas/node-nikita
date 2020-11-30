
# `nikita.lxd.start`

Start containers.

## Callback Parameters

* `err`
  Error object if any.
* `info.status`
  Was the container started or already running.

## Example

```js
const {status} = await nikita.lxd.start({
  container: "my_container"
})
console.info(`Container was started: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
      required: ['container']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd.start", level: 'DEBUG', module: '@nikitajs/lxd/lib/start'
      cmd_init = [
        'lxc', 'start', config.container
      ].join ' '
      # Execution
      @execute
        cmd: """
        lxc list -c ns --format csv | grep '#{config.container},RUNNING' && exit 42
        #{cmd_init}
        """
        code_skipped: 42

## Export

    module.exports =
      handler: handler
      schema: schema
