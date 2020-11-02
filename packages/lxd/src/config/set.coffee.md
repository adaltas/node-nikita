
# `nikita.lxd.config.set`

Set container or server configuration keys.

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

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
        'config':
          type: 'object'
          patternProperties: '': type: ['string', 'boolean', 'number']
          description: """
          One or multiple keys to set.
          """
      required: ['container', 'config']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd.config.set", level: 'DEBUG', module: '@nikitajs/lxd/lib/config/set'
      # Normalize config
      for k, v of config.config
        continue if typeof v is 'string'
        config.config[k] = v.toString()
      keys = {}
      {stdout} = await @execute
        cmd: """
        #{[
          'lxc', 'config', 'show'
          config.container
        ].join ' '}
        """
        shy: true
        code_skipped: 42
      stdout = yaml.safeLoad stdout
      changes = diff stdout.config, merge stdout.config, config.config
      # if changes is empty status is false because no command were executed
      # Note, it doesnt seem possible to set multiple keys in one command
      {status} = await @execute (
        cmd: [
          'lxc', 'config', 'set'
          config.container
          key, "'#{value.replace '\'', '\\\''}'"
        ].join ' '
      ) for key, value of changes
      status: status

## Exports

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    {merge} = require 'mixme'
    yaml = require 'js-yaml'
    diff = require 'object-diff'
