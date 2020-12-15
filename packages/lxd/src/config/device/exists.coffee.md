
# `nikita.lxd.config.device.exists`

Check if the device exists in a container.

## Callback parameters

* `err`
  Error object if any.
* `result.status`
  True if the device exist, false otherwise.

## Add a network interface

```js
const {status, config} = await nikita.lxd.config.device.exists({
  container: "my_container",
  device: 'eth0'
})
console.info(status ? `device exists, type is ${config.type}` : 'device missing')
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
      # log message: "Entering lxd.config.device.exists", level: 'DEBUG', module: '@nikitajs/lxd/lib/config/device/exists'
      {properties} = await @lxd.config.device.show
        container: config.container
        device: config.device
      exists: !!properties, properties: properties

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema
