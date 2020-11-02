
# `nikita.lxd.storage`

Create a storage or update a storage configuration.

## Callback Parameters

* `err`
  Error object if any
* `status`
  Was the storage created or updated

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
  console.info( err ? err.message : 'The storage was created or config updated')
});
```

## Schema

    schema =
      type: 'object'
      properties:
        'name':
          type: 'string'
          description: """
          The storage name to create or update.
          """
        'driver':
          type: 'string'
          enum: ["btrfs", "ceph", "cephfs", "dir", "lvm", "zfs"]
          description: """
          The underlying driver name. Can be btrfs, ceph, cephfs, dir, lvm, zfs.
          """
        'config':
          type: 'object',
          patternProperties: '': type: ['string', 'boolean', 'number']
          description: """
          The configuration to use to configure this storage, depends on the
          driver. See [available
          fields](https://lxd.readthedocs.io/en/latest/storage/).
          """
      required: ['name', 'driver']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd.storage", level: 'DEBUG', module: '@nikitajs/lxd/lib/storage'
      # Normalize config
      for k, v of config.config
        continue if typeof v is 'string'
        config.config[k] = v.toString()
      # Check if exists
      {stdout, code} = await @execute
        cmd: """
        lxc storage show #{config.name} && exit 42
        #{['lxc', 'storage', 'create'
          config.name
          config.driver
          (("#{key}='#{value.replace '\'', '\\\''}'") for key, value of config.config).join ' '
        ].join ' '}
        """
        code_skipped: 42
      return unless code is 42
      # Storage already exists, find the changes
      return unless config?.config
      stdout = yaml.safeLoad stdout
      changes = diff stdout.config, config.config
      # if changes is empty status is false because no command were executed
      {status} = await @execute (
        cmd: [
          'lxc', 'storage', 'set'
          config.name
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
