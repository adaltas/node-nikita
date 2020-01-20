
# `nikita.lxd.config.device`

Create a device or update its configuration.

## Options

* `container` (string, required)
  The name of the container.
* `device` (string, required)
  Name of the device in LXD configuration, for example "eth0".
* `config` (object, required)
  One or multiple keys to set.
* `type` (string, required)
  Type of device, see [list of devices type](https://github.com/lxc/lxd/blob/master/doc/containers.md#device-types).

## Callback parameters

* `err`
  Error object if any.
* `result.status`
  True if the device was created or the configuraion updated.

## Example

```js
require('nikita')
.lxd.config.device({
  container: 'container1',
  device: 'root',
  type: 'disk'
  config: {
    'pool': 'system',
    'size': '10GB'
  }
}, function(err, {status}){
  console.log( err ? err.message : 'Network created: ' + status);
})
```

## Source Code

    module.exports = handler: ({options}, callback) ->
      @log message: "Entering lxd config.device", level: "DEBUG", module: "@nikitajs/lxd/lib/config/device"
      #Check args
      valid_devices = ['none', 'nic', 'disk', 'unix-char', 'unix-block', 'usb', 'gpu', 'infiniband', 'proxy']
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      throw Error "Invalid Option: Device name (options.device) is required" unless options.device
      @lxd.config.device.show
        container: options.container
        device: options.device
      , (err, {status, config}) ->
        return callback err if err
        unless config
          return callback Error "Invalid Option: Unrecognized device type: #{options.type}, valid devices are: #{valid_devices.join ', '}" unless options.type in valid_devices
          for k, v of options.config
            continue if typeof v is 'string'
            options.config[k] = if typeof v is 'boolean' then if v then 'true' else 'false'
          @system.execute
            cmd: [
              'lxc', 'config', 'device', 'add',
              options.container
              options.device
              options.type
              ...(
                "#{key}='#{value.replace '\'', '\\\''}'" for key, value of options.config
              )
            ].join ' '
          , (err, {stderr}) ->
            stderr_to_error_message err, stderr if err
            return callback err, status: true
        else
          changes = diff config, options.config
          return callback null, status: false if not Object.keys(changes).length
          @system.execute
            cmd: (
              [
                'lxc', 'config', 'device', 'set'
                options.container
                options.device
                key, "'#{value.replace '\'', '\\\''}'"
              ].join ' ' for key, value of changes
            ).join '\n'
          , (err, {stderr}) ->
            stderr_to_error_message err, stderr if err
          @next (err) ->
            return callback err, status: true

## Dependencies

    diff = require 'object-diff'
    validate_container_name = require '../../misc/validate_container_name'
    stderr_to_error_message = require '../../misc/stderr_to_error_message'
