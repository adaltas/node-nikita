
# `nikita.lxd.running`

Check if container is running.

## Output

* `$status`
  Was the container started or already running.

## Example

```js
const {$status} = await nikita.lxd.running({
  container: "my_container"
})
console.info(`Container is running: ${$status}`)
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
        lxc list -c ns --format csv | grep '#{config.container},RUNNING' || exit 42
        """
        code_skipped: 42

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema
        shy: true
