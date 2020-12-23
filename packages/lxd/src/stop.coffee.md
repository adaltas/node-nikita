
# `nikita.lxd.stop`

Stop a running Linux Container.

## Example

```js
const {status} = await nikita.lxd.stop({
  container: "myubuntu"
})
console.info(`The container was stopped: ${status}`)
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
      # log message: "Entering stop", level: 'DEBUG', module: '@nikitajs/lxd/lib/stop'
      await @execute
        command: """
        lxc list -c ns --format csv | grep '#{config.container},STOPPED' && exit 42
        lxc stop #{config.container}
        """
        code_skipped: 42

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema
