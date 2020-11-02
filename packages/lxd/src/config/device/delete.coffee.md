
# `nikita.lxd.config.delete`

Delete a device from a container

## Callback parameters

* `err`
  Error object if any.
* `result.status`
  True if the device was removed False otherwise.

## Example

```js
require('nikita')
.lxd.config.device.delete({
  container: 'container1',
  device: 'root',
}, function(err, {status}){
  console.info( err ? err.message : 'Device removed: ' + status);
})
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
      # log message: "Entering lxd config.device.delete", level: "DEBUG", module: "@nikitajs/lxd/lib/config/device/delete"
      config_orig = config
      {config} = await @lxd.config.device.show
        container: config.container
        device: config.device
      return status: false if not config
      {status} = await @execute
        cmd: [
          'lxc', 'config', 'device', 'remove'
          config_orig.container
          config_orig.device
        ].join ' '
      status: status

## Export

    module.exports =
      handler: handler
      schema: schema
