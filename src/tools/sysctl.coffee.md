
# `nikita.tools.sysctl(options, callback)`

Configure kernel parameters at runtime.

## Options

* `load` (boolean)   
  Load properties if target is modified, default is "true".   
* `source` (object)   
  List of properties to write and load.   
* `target` (string)
  Destination to write properties and load in sysctl settings, default to "/etc/sysctl.conf" if none given.

## Callback parameters

* `err` (Error)   
  Error object if any.   
* `status`  (boolean)   
  Value is "true" if backup was created.   

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
      options.load ?= true
      options.target ?= '/etc/sysctl.conf'
      # Read current properties
      current = {}
      @call (_, callback) ->
        status = false
        fs.readFile options.ssh, options.target, 'ascii', (err, data) =>
          return callback err if err
          for row in misc.split data
            [key, value] = row.split '='
            # Preserve comments
            if /^#/.test key
              current[key] = null
              continue
            # Trim
            key = key.trim()
            value = value.trim()
            # Skip property
            if key in options.properties and not options.properties[key]?
              options.log "Removing Property: #{key}, was #{value}"
              status = true
              continue
            # Set property
            if options.properties[key] isnt value
              current[key] = value
              status = true
          callback null, status
      @call
        if: [
          options.load
          -> @status()
        ]
      , ->
        @file
          target: "#{options.target}"
          content: (
            for key, value of current
              if value?
                "#{key} = #{value}"
              else
                "#{key}"
          ).join '\n'
      @system.execute
        if: -> @status()
        cmd: "sysctl -p #{options.target}"
