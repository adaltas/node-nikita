
# `nikita.tools.sysctl(options, callback)`

Configure kernel parameters at runtime.

Target file will be overwritten by default, use the `merge` option to preserve existing variables.

Comments will be preserved if the `comments` and `merge` options are enabled.

## Options

* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `comment` (boolean)   
  Preserve comments.
* `load` (boolean)   
  Load properties if target is modified, default is "true".
* `merge` (boolean)    
  Preserve existing variables in the target file.
* `properties` (object)   
  Key/value object representing sysctl properties and values.
* `target` (string)
  Destination to write properties and load in sysctl settings, default to "/etc/sysctl.conf" if none given.

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

## Example

```js
require('nikita').tools.sysctl({
  source: '/etc/sysctl.conf',
  properties: {
    'vm.swappiness': 1
  }
}, function(err, status){
  console.log(err ? err.message : 'Systcl reloaded: ' + !!status);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering sysctl", level: 'DEBUG', module: 'nikita/lib/tools/sysctl'
      # Options
      options.load ?= true
      options.target ?= '/etc/sysctl.conf'
      # Read current properties
      current = {}
      @call (_, callback) ->
        status = false
        options.log message: "Read target: #{options.target}", level: 'DEBUG', module: 'nikita/lib/tools/sysctl'
        @fs.readFile
          ssh: options.ssh
          target: options.target
          encoding: 'ascii'
        , (err, data) =>
          return callback() if err and err.code is 'ENOENT'
          return callback err if err
          for line in string.lines data
            # Preserve comments
            if /^#/.test line
              current[line] = null if options.comment
              continue
            if /^\s*$/.test line
              current[line] = null
              continue
            [key, value] = line.split '='
            # Trim
            key = key.trim()
            value = value.trim()
            # Skip property
            if key in options.properties and not options.properties[key]?
              options.log "Removing Property: #{key}, was #{value}", level: 'INFO', module: 'nikita/lib/tools/sysctl'
              status = true
              continue
            # Set property
            current[key] = value
          callback null, status
      # Merge user properties
      final = {}
      @call (_, callback) ->
        final[k] = v for k, v of current if options.merge
        status = false
        for key, value of options.properties
          continue unless value?
          value = "#{value}" if typeof value is 'number'
          continue if current[key] is value
          options.log "Update Property: key \"#{key}\" from \"#{final[key]}\" to \"#{value}\"", level: 'INFO', module: 'nikita/lib/tools/sysctl'
          final[key] = value
          status = true
        callback null, status
      @call
        if: -> @status()
      , ->
        @file
          target: options.target
          backup: options.backup
          content: (
            for key, value of final
              if value?
                "#{key} = #{value}"
              else
                "#{key}"
          ).join '\n'
      @system.execute
        if: [
          options.load
          -> @status()
        ]
        cmd: "sysctl -p #{options.target}"

## Dependencies

    string = require '../misc/string'
