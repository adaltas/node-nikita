
# `nikita.lxd.config.device`

Create a device or update its configuration.

## Callback parameters

* `err`
  Error object if any.
* `result.status`
  True if the device was created or the configuraion updated.

## Example

```js
const {status} = await nikita.lxd.config.device({
  config: {
    container: 'container1',
    device: 'root',
    type: 'disk',
    config: {
      'pool': 'system',
      'size': '10GB'
    }
  }
})
console.info(`Disk was created: ${status}`)
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
        'config':
          type: 'object'
          patternProperties: '': type: ['string', 'boolean', 'number']
          description: """
          One or multiple keys to set depending on the type.
          """
        'type':
          type: 'string'
          description: """
          Type of device, see [the list of device
          types](https://lxd.readthedocs.io/en/latest/instances/#device-types).
          """
      oneOf: [
          properties:
            'config': const: {}
            'type': const: 'none'
        ,
          properties: 'type': const: 'nic'
        ,
          properties:
            'config':
              properties:
                'path':
                  type: 'string'
                  description: """
                  Path inside the instance where the disk will be mounted (only
                  for containers).
                  """
                'source':
                  type: 'string'
                  description: """
                  Path on the host, either to a file/directory or to a block
                  device.
                  """
              required: ['path', 'source']
            'type': const: 'disk'
        ,
          properties: 'type': const: 'unix-char'
        ,
          properties: 'type': const: 'unix-block'
        ,
          properties: 'type': const: 'usb'
        ,
          properties: 'type': const: 'gpu'
        ,
          properties:
            'config':
              properties:
                'connect':
                  type: 'string'
                  description: """
                  The address and port to bind and listen
                  (<type>:<addr>:<port>[-<port>][,<port>])
                  """
                'parent':
                  type: 'string'
                  description: """
                  The address and port to connect to
                  (<type>:<addr>:<port>[-<port>][,<port>])
                  """
              required: ['connect', 'listen']
            'type': const: 'proxy'
        ,
          properties:
            'config':
              properties:
                'path':
                  type: 'string'
                  description: """
                  Path inside the instance (only for containers).
                  """
              required: ['path']
            'type': const: 'unix-hotplug'
        ,
          properties: 'type': const: 'tpm'
        ,
          properties:
            'config':
              properties:
                'nictype':
                  type: 'string'
                  enum: ['physical', 'sriov']
                  description: """
                  The device type, one of "physical", or "sriov".
                  """
                'parent':
                  type: 'string'
                  description: """
                  The name of the host device or bridge.
                  """
              required: ['nictype', 'parent']
            'type': const: 'infiniband'
      ]
      required: ['container', 'config', 'device', 'type']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd config.device", level: "DEBUG", module: "@nikitajs/lxd/lib/config/device"
      # Normalize config
      for k, v of config.config
        continue if typeof v is 'string'
        config.config[k] = v.toString()
      config_orig = config
      {config} = await @lxd.config.device.show
        container: config.container
        device: config.device
      try
        unless config
          {status} = await @execute
            command: [
              'lxc', 'config', 'device', 'add',
              config_orig.container
              config_orig.device
              config_orig.type
              ...(
                "#{key}='#{value.replace '\'', '\\\''}'" for key, value of config_orig.config
              )
            ].join ' '
        else
          changes = diff config, config_orig.config
          {status} = await @execute (
            command: [
              'lxc', 'config', 'device', 'set'
              config_orig.container
              config_orig.device
              key, "'#{value.replace '\'', '\\\''}'"
            ].join ' '
          ) for key, value of changes
        status: status
      catch err
        stderr_to_error_message err, err.stderr
        throw err

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    diff = require 'object-diff'
    stderr_to_error_message = require '../../misc/stderr_to_error_message'
