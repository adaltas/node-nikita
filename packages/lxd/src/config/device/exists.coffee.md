
# `nikita.lxd.config.device.exists`

Check if the device exists in a container.

## Callback parameters

* `err`
  Error object if any.
* `result.status`
  True if the device exist, false otherwise.

## Add a network interface

```js
require('nikita')
.lxd.config.device.exists({
  container: "my_container",
  device: 'eth0',
}, function(err, {status, config}) {
  console.info( err ? err.message : status ?
    'device exists, type is' + config.type : 'device missing')
});
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
      {config} = await @lxd.config.device.show
        container: config.container
        device: config.device
      status: !!config, config: config

## Export

    module.exports =
      handler: handler
      schema: schema
