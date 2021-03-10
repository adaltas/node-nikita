
# `nikita.lxc.stop`

Stop a running Linux Container.

## Example

```js
const {$status} = await nikita.lxc.stop({
  container: "myubuntu"
})
console.info(`The container was stopped: ${$status}`)
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
