
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

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering lxd.config.device.add", level: 'DEBUG', module: '@nikitajs/lxd/lib/config/device/add'
      #Execute
      @system.execute
        cmd: """
        #{[
          'lxc', 'config', 'device', 'show'
          options.container
        ].join ' '}
        """
        code_skipped: 42
      , (err, {stdout}) ->
        throw err if err
        config = yaml.safeLoad stdout
        console.log config
        throw Error 'stop'

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
