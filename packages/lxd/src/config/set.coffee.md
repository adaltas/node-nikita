
# `nikita.lxd.config.set`

Set container or server configuration keys.

## Options

* `container` (string, required)
  The name of the container.
* `config` (object, required)
  One or multiple keys to set.

## Set a configuration key

```js
require('nikita')
.lxd.config.set({
  name: "my_container",
  config:
    'boot.autostart.priority': 100,
}, function(err, {status}) {
  console.info( err ? err.message : status ?
    'Property set' : 'Property already present')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering lxd.config.set", level: 'DEBUG', module: '@nikitajs/lxd/lib/config/set'
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      # Execution
      keys = {}
      @system.execute
        cmd: """
        #{[
          'lxc', 'config', 'show'
          options.container
        ].join ' '}
        """
        shy: true
        code_skipped: 42
      , (err, {stdout}) ->
        throw err if err
        config = yaml.safeLoad stdout
        keys = diff config.config, merge config.config, options.config
      @call ->
        # Note, it doesnt seem possible to set multiple keys in one command
        @system.execute
          if: Object.keys(keys).length
          cmd: """
          #{(
            [
              'lxc', 'config', 'set', options.container
              "#{k} '#{v.replace '\'', '\\\''}'"
            ].join ' ' for k, v of keys
          ).join '\n'}
          """
          code_skipped: 42


## Dependencies

    {merge} = require 'mixme'
    yaml = require 'js-yaml'
    diff = require 'object-diff'
    validate_container_name = require '../misc/validate_container_name'
