
# `nikita.lxd.config.delete`

Delete a device from a container

## Options

* `container` (string, required)
  The name of the container.
* `device` (string, required)
  Name of the device in LXD configuration, for example "eth0".

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
  console.log( err ? err.message : 'Device removed: ' + status);
})
```

## Source Code

    module.exports = handler: ({options}, callback) ->
      @log message: "Entering lxd config.device", level: "DEBUG", module: "@nikitajs/lxd/lib/config/device/delete"
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      throw Error "Invalid Option: Device name (options.device) is required" unless options.device
      @lxd.config.device.show
        container: options.container
        device: options.device
      , (err, {status, config}) ->
        return callback err, status: false if err or not config
        @system.execute
          cmd: [
            'lxc', 'config', 'device', 'remove'
            options.container
            options.device
          ].join ' '
        , (err, {status}) ->
        return callback err if err
        return callback null, status: true

## Dependencies

    validate_container_name = require '../../misc/validate_container_name'
