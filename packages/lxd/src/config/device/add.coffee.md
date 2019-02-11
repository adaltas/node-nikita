
# `nikita.lxd.config.device.add`

Add devices to containers or profiles.

## Options

* `name` (string, required)   
  The name of the container.
* `device` (string, required)   
  Name of the device in LXD configuration, for example "eth0".
* `config` (object, required)   
  One or multiple keys to set.
* `type` (string, required)   
  Type of device, for example "nic".

## Add a network interface

```js
require('nikita')
.lxd.config.device.add({
  name: "my_container",
  device: 'eth0',
  type: 'nic',
  config:
    name: 'eth0',
    nictype: 'bridged',
    parent: 'lxdbr0'
}, function(err, {status}) {
  console.log( err ? err.message : status ?
    'bidge added' : 'bridge already present')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering lxd.config.device.add", level: 'DEBUG', module: '@nikitajs/lxd/lib/config/device/add'
      throw Error "Invalid Option: name is required" unless options.name
      throw Error "Invalid Option: device is required" unless options.device
      options.config ?= {}
      @lxd.config.device.exists
        name: options.name
        device: options.device
      @system.execute
        unless: -> @status -1
        cmd: """
        #{[
          'lxc', 'config', 'device', 'add'
          options.name
          options.device
          options.type
          ...(
            "#{key}='#{value.replace '\'', '\\\''}'" for key, value of options.config
          )
        ].join ' '}
        """
        code_skipped: 42

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
