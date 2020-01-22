
# `nikita.lxd.network`

Create a network or update a network configuration

## Options

* `network` (required, string)
  The network name.
* `config` (optional, object, {})
  The network configuration, see
  [available fields](https://lxd.readthedocs.io/en/latest/networks/).

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
  console.log( err ? err.message : 'Network created: ' + status);
})
```

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering lxd.network", level: "DEBUG", module: "@nikitajs/lxd/lib/network"
      #Check args
      throw Error "Invalid Option: network is required to create a network" unless options.network
      for k, v of options.config
        continue if typeof v is 'string'
        options.config[k] = if typeof v is 'boolean' then if v then 'true' else 'false'
      # Command if the network does not yet exist
      @system.execute
        # return code 5 indicates a version of lxc where 'network' command is not implemented
        cmd: """
        lxc network > /dev/null || exit 5
        lxc network show #{options.network} && exit 42
        #{[
          'lxc',
          'network',
          'create'
          options.network
          ...(
            "#{key}='#{value.replace '\'', '\\\''}'" for key, value of options.config
          )
        ].join ' '}
        """
        code_skipped: 42
      , (err, {stdout, code, status}) ->
        return callback Error "This version of lxc does not support the network command" if code is 5
        return callback err, status: status unless code is 42 # was created
        {config} = yaml.safeLoad stdout
        changes = diff config, options.config
        @system.execute (
          cmd: [
            'lxc', 'network', 'set'
            options.network
            key, "'#{value.replace '\'', '\\\''}'"
          ].join ' '
        ) for key, value of changes
        return callback null, Object.keys(changes).length > 0

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
