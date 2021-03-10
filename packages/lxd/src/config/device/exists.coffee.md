
# `nikita.lxc.config.device.exists`

Check if the device exists in a container.

## Output

* `$status`
  True if the device exist, false otherwise.

## Add a network interface

```js
const {$status, config} = await nikita.lxc.config.device.exists({
  container: "my_container",
  device: 'eth0'
})
console.info($status ? `device exists, type is ${config.type}` : 'device missing')
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
        'device':
          type: 'string'
          description: """
          Name of the device in LXD configuration, for example "eth0".
          """
      required: ['container', 'device']

## Handler

    handler = ({config}) ->
      {properties} = await @lxc.config.device.show
        container: config.container
        device: config.device
      exists: !!properties, properties: properties

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema
