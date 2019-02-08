
# `nikita.lxd.network`

Create a network or update a network configuration

## Options

* `name` (required, string)
  The network name
* `config` (optional, object, {})
  The network configuration, see available fields here: https://lxd.readthedocs.io/en/latest/networks/

## Callback parameters

* `err`
  Error object if any
* `status`
  True if the network was created/updated

## Example

```js
require('nikita')
.lxd.network({
  name: 'lxbr0'
  config: {
    'ipv4.address': '172.89.0.0/24',
    'ipv6.address': 'none'
  }
}, function(err, {status}){
  console.log( err ? err.message : 'Network created: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd network", level: "DEBUG", module: "@nikitajs/lxd/lib/network"
      #Check args
      throw Error "Argument 'name' is required to create a network" unless options.name
      # Command if the network does not yet exist
      cmd_create = [
        'lxc',
        'network',
        'create'
        options.name
        "#{key}=\"#{value}\"" for key, value of options.config
      ].join ' '
      @system.execute
        # return code 5 indicates a version of lxc where 'network' command is not implemented
        cmd: """
        lxc network > /dev/null || exit 5
        lxc network show #{options.name} && exit 42
        #{cmd_create}
        """
        code_skipped: 42
      , (err, {stdout, code}) ->
        throw Error "This version of lxc does not support the network command" if code == 5
        if code == 42 # network exists
          # what to modify for this network
          config = diff(yaml.load(stdout).config, options.config)
          # if config is empty status is false because no command were executed
          for key, value of config
            cmd = [].join ' '
            @system.execute
              cmd: "lxc network set #{options.name} #{key} \"#{value}\""
              # trap  if a command fails ?

## Module Requirements

    yaml = require 'yaml-js'
    diff = require 'object-diff'
