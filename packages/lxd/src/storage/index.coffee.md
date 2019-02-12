
# `nikita.lxd.storage`

Creates or updates a storage configuration.

## Options

* `name` (required, string)
  The storage name
* `driver` (required, string)
  The underlying driver name. Can be btrfs, ceph, dir, lvm, zfs
* `config` (optional, object, {})
  The configuration to use to configure this storage, depends on the driver

## Callback Parameters

* `err`
  Error object if any
* `status`
  Was the storage created

## Example

```
require('nikita')
.lxd.storage({
  name: "system",
  driver: "zfs",
  config: {
    source: "syspool/lxd"
  }
}, function(err, {status}) {
  console.log( err ? err.message : 'The storage was created or config updated')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering lxd.storage", level: 'DEBUG', module: '@nikitajs/lxd/lib/storage'
      throw Error "Invalid Option: name is required" unless options.name
      throw Error "Invalid Option: driver is required" unless options.driver
      throw Error "Invalid driver: #{options.driver}"　unless options.driver in ["btrfs", "ceph", "dir", "lvm", "zfs"]
      @system.execute
        cmd: """
        lxc storage show #{options.name} && exit 42
        #{['lxc', 'storage', 'create'
          options.name
          options.driver
          "#{key}='#{value.replace '\'', '\\\''}'" for key, value of options.config
        ].join ' '}
        """
        code_skipped: 42
      , (err, {stdout, code}) ->
      # Storage created
        return unless code is 42
        # Storage already exists, find the changes
        {config} = yaml.safeLoad stdout
        changes = diff config, options.config
        # if config is empty status is false because no command were executed
        @system.execute (
          cmd: [
            'lxc', 'storage', 'set'
            options.name
            key, "'#{value.replace '\'', '\\\''}'"
          ].join ' '
        ) for key, value of changes

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
