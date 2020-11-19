
# `nikita.tools.sysctl`

Configure kernel parameters at runtime.

Target file will be overwritten by default, use the `merge` option to preserve existing variables.

Comments will be preserved if the `comments` and `merge` config are enabled.

## Callback parameters

* `err` (Error)   
  Error object if any.   
* `status`  (boolean)   
  Value is "true" if the property was created or updated.

## Usefull Commands

* Display all sysctl variables   
  `sysctl -a`
* Display value for a kernel variable   
  `sysctl -n kernel.hostname`
* Set a kernel variable
  `echo "value" > /proc/sys/location/variable`
  `echo 'variable = value' >> /etc/sysctl.conf && sysctl -p`
  `echo '0' > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a | grep 'fs.protected_regular = 0'`

## Example

```js
require('nikita').tools.sysctl({
  source: '/etc/sysctl.conf',
  properties: {
    'vm.swappiness': 1
  }
}, function(err, {status}){
  console.info(err ? err.message : 'Systcl reloaded: ' + status);
});
```

## Schema

    schema =
      type: 'object'
      properties:
        'backup':
          oneOf: [
            type: 'string'
          ,
            type: 'boolean'
          ]
          description: """
          Create a backup, append a provided string to the filename extension or
          a timestamp if value is not a string, only apply if the target file
          exists and is modified.
          """
        'comment':
          type: 'boolean'
          description: """
          Preserve comments.
          """
        'load':
          type: 'boolean'
          default: true
          description: """
          Load properties if target is modified.
          """
        'merge':
          type: 'boolean'
          description: """
          Preserve existing variables in the target file.
          """
        'properties':
          type: 'object'
          description: """
          Key/value object representing sysctl properties and values.
          """
        'target':
          type: 'string'
          default: '/etc/sysctl.conf'
          description: """
          Destination to write properties and load in sysctl settings, default
          to "/etc/sysctl.conf" if none given.
          """

## Handler

    handler = ({config, tools: {log}}) ->
      # Read current properties
      current = {}
      status = false
      log message: "Read target: #{config.target}", level: 'DEBUG', module: 'nikita/lib/tools/sysctl'
      try
        {data} = await @fs.base.readFile
          ssh: config.ssh
          target: config.target
          encoding: 'ascii'
        for line in utils.string.lines data
          # Preserve comments
          if /^#/.test line
            current[line] = null if config.comment
            continue
          if /^\s*$/.test line
            current[line] = null
            continue
          [key, value] = line.split '='
          # Trim
          key = key.trim()
          value = value.trim()
          # Skip property
          if key in config.properties and not config.properties[key]?
            log "Removing Property: #{key}, was #{value}", level: 'INFO', module: 'nikita/lib/tools/sysctl'
            status = true
            continue
          # Set property
          current[key] = value
      catch err
        throw err unless err.code is 'NIKITA_FS_CRS_TARGET_ENOENT'
      # Merge user properties
      final = {}
      final[k] = v for k, v of current if config.merge
      status = false
      for key, value of config.properties
        continue unless value?
        value = "#{value}" if typeof value is 'number'
        continue if current[key] is value
        log "Update Property: key \"#{key}\" from \"#{final[key]}\" to \"#{value}\"", level: 'INFO', module: 'nikita/lib/tools/sysctl'
        final[key] = value
        status = true
      if status
        @file
          target: config.target
          backup: config.backup
          content: (
            for key, value of final
              if value?
                "#{key} = #{value}"
              else
                "#{key}"
          ).join '\n'
      if config.load and status
        @execute "sysctl -p #{config.target}"

## Exports

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    utils = require './utils'
