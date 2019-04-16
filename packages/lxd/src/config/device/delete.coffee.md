
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
* `status`
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
      #Check args
      throw Error "Invalid Option: Container name (options.container) is required" unless options.container
      throw Error "Invalid Option: Device name (options.device) is required" unless options.device

      @lxd.config.device.exists
        container: options.container
        device: options.device
      , (err, {status, config}) ->
        return callback err if err
        return callback null, status: false unless status
        @system.execute
          cmd:"""
          lxc config device remove #{options.container} #{options.device}
          """
        , (err, {status}) ->
        return callback err if err
        return callback null, status: true
