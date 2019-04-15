
# `nikita.lxd.config.device`

Create or update a device's configuration

## Options

* `name` (string, required)
  The name of the container.
* `device` (string, required)
  Name of the device in LXD configuration, for example "eth0".
* `config` (object, required)
  One or multiple keys to set.
* `type` (string, required)
  Type of device, see [list of devices type](https://github.com/lxc/lxd/blob/master/doc/containers.md#device-types).

## Callback parameters

* `err`
  Error object if any
* `status`
  True if the device was created or the configuraion updated.

## Example

```js
require('nikita')
.lxd.config.device({
  name: 'container1',
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
      throw Error "Invalid Option: Container name is required" unless options.name
      throw Error "Invalid Option: Device name is required" unless options.device

      @lxd.config.device.exists
        name: options.name
        device: options.device
      , (err, {status, config}) ->
        if not status
          throw Error "Invalid Option: Unrecognized device type, valid devices are: #{valid_devices.join ', '}" unless options.type in valid_devices
          for k, v of options.config
            continue if typeof v is 'string'
            options.config[k] = if typeof v is 'boolean' then if v then 'true' else 'false'
          @system.execute
            cmd: """
            #{[
              'lxc', 'config', 'device', 'add',
              options.name, options.device, options.type
              ...(
                "#{key}='#{value.replace '\'', '\\\''}'" for key, value of options.config
              )
            ].join ' '}
            """
          , (err, {status}) ->
            return callback err, status: false if err
            return callback undefined, status: true
        else
          changes = diff config[options.device], options.config
          return callback undefined, status: false if not Object.keys(changes).length
          @system.execute (
            cmd: [
              'lxc', 'config', 'device', 'set'
              options.name
              options.device
              key, "'#{value.replace '\'', '\\\''}'"
            ].join ' '
          ) for key, value of changes
          return callback undefined, status: true

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
