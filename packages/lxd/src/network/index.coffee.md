
# `nikita.lxd.network`

Create a network or update a network configuration

## Callback parameters

* `err`
  Error object if any
* `status`
  True if the network was created/updated

## Example

```js
require('nikita')
.lxd.network({
  network: 'lxbr0'
  config: {
    'ipv4.address': '172.89.0.0/24',
    'ipv6.address': 'none'
  }
}, function(err, {status}){
  console.info( err ? err.message : 'Network created: ' + status);
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'network':
          type: 'string'
          description: """
          The network name to create.
          """
        'config':
          type: 'object'
          patternProperties: '': type: ['string', 'boolean', 'number']
          description: """
          The network configuration, see [available
          fields](https://lxd.readthedocs.io/en/latest/networks/).
          """
      required: ['network']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd.network", level: "DEBUG", module: "@nikitajs/lxd/lib/network"
      # Normalize config
      for k, v of config.config
        continue if typeof v is 'string'
        config.config[k] = v.toString()
      # Command if the network does not yet exist
      {stdout, code, status} = await @execute
        # return code 5 indicates a version of lxc where 'network' command is not implemented
        cmd: """
        lxc network > /dev/null || exit 5
        lxc network show #{config.network} && exit 42
        #{[
          'lxc',
          'network',
          'create'
          config.network
          ...(
            "#{key}='#{value.replace '\'', '\\\''}'" for key, value of config.config
          )
        ].join ' '}
        """
        code_skipped: [5, 42]
      throw Error "This version of lxc does not support the network command." if code is 5
      return status: status unless code is 42 # was created
      # Network already exists, find the changes
      return unless config?.config
      config_orig = config
      {config} = yaml.safeLoad stdout
      changes = diff config, config_orig.config
      {status} = await @execute (
        cmd: [
          'lxc', 'network', 'set'
          config_orig.network
          key, "'#{value.replace '\'', '\\\''}'"
        ].join ' '
      ) for key, value of changes
      status: status

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
