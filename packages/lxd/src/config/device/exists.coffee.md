
# `nikita.lxd.config.device.exists`

Add devices to containers or profiles.

## Options

* `name` (string, required)   
  The name of the container.
* `device` (string, required)   
  Name of the device in LXD configuration, for example "eth0".

## Add a network interface

```js
require('nikita')
.lxd.config.device.exists({
  name: "my_container",
  device: 'eth0',
}, function(err, {status, config}) {
  console.log( err ? err.message : status ?
    'device exists, type is' + config.type : 'device missing')
});
```

## Source Code

    module.exports = shy: true, handler: ({options}, callback) ->
      @log message: "Entering lxd.config.device.exists", level: 'DEBUG', module: '@nikitajs/lxd/lib/config/device/exists'
      throw Error "Invalid Option: name is required" unless options.name
      throw Error "Invalid Option: device is required" unless options.device
      @system.execute
        cmd: """
        #{[
          'lxc', 'config', 'device', 'show'
          options.name
        ].join ' '}
        """
        code_skipped: 42
        shy: true
      , (err, {stdout}) ->
        return callback err if err
        config = yaml.safeLoad stdout
        callback null, status: !!config[options.device], config: config

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
