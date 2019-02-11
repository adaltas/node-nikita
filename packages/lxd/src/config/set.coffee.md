
# `nikita.lxd.config.set`

Set container or server configuration keys.

## Options

* `name` (string, required)   
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
  console.log( err ? err.message : status ?
    'Property set' : 'Property already present')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering lxd.config.set", level: 'DEBUG', module: '@nikitajs/lxd/lib/config/set'
      #Execute
      @system.execute
        cmd: """
        #{[
          'lxc', 'config', 'show'
          options.container
        ].join ' '}
        """
        code_skipped: 42
      , (err, {stdout}) ->
        throw err if err
        config = yaml.safeLoad stdout
        console.log config
        throw Error 'stop'

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
