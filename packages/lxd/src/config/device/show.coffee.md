
# `nikita.lxd.config.device.show`

Show full device configuration for containers or profiles

## Options

* `container` (string, required)
  The name of the container.
* `device` (string, required)
  Name of the device in LXD configuration, for example "eth0".

## Output parameters

* `err`
  Error object if any.
* `result.status` (boolean)
  True if the device was created or the configuraion updated.
* `result.config` (object)   
  Device configuration.

## Example

```js
require('nikita')
.lxd.config.device.show({
  container: 'container1',
  device: 'vpn'
}, function(err, {config}){
  console.log( err ? err.message : config);
  # { connect: "udp:127.0.0.1:1194",
  #   listen: "udp:51.68.116.44:1194",
  #   type: proxy } }
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'container': type: 'string'

## Handler

    handler = ({options}, callback) ->
      @log message: "Entering lxd config.device.show", level: "DEBUG", module: "@nikitajs/lxd/lib/config/device/show"
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      throw Error "Invalid Option: Device name (options.device) is required" unless options.device
      @system.execute
        cmd: [
          'lxc', 'query'
          '/' + [
            '1.0', 'containers', options.container
          ].join '/'
        ].join ' '
      , (err, {stdout}) ->
        return callback err if err
        config = JSON.parse stdout
        callback null, status: true, config: config.devices[options.device]

## Exports

    module.exports =
      handler: handler
      schema: schema
      shy: true

## Dependencies

    validate_container_name = require '../../misc/validate_container_name'
