
# `nikita.tools.npm.uninstall`

Remove one or more NodeJS packages.

## Options

* `name` (string|array, required)
  Name of the package(s).
* `global` (boolean)
  Uninstalls the current package context as a global package.

## Callback Parameters

* `err`
  Error object if any.
* `status`
  Value "true" if the package was uninstalled.

## Example

The following action uninstalls the coffescript package globally.

```javascript
require('nikita')
.tools.npm({
  name: 'coffeescript',
  global: true
}, (err, {status}) => {
  console.log(err ? err.message : 'Package uninstalled ' + status);
});
```

## Schema

    schema =
      type: 'object'
      properties:
        'name':
          oneOf: [{type: 'string'}, {type: 'array', items: type: 'string'}]
          description: 'Name of the package(s).'
        'global':
          type: 'boolean'
          default: false
          description: 'Uninstalls the current package context as a global package.'
      required: ['name']

## Handler

    handler = ({options}, callback) ->
      options.name = options.argument if options.argument?
      options.name = [options.name] if typeof options.name is 'string'
      global = if options.global then ' -g' else ''
      installed = []
      @system.execute
        cmd: "npm list --installed --json #{global}"
        code: [0, 1]
        stdout_log: false
        shy: true
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        pkgs = Object.keys pkgs.dependencies
        installed = pkgs
      @call ->
        uninstall = options.name.filter (pkg) -> pkg in installed
        @system.execute
          if: uninstall.length
          cmd: "npm uninstall #{global} #{uninstall.join ' '}"
          sudo: options.sudo
        , (err) =>
          @log message: "NPM uninstalled packages: #{install.join ', '}"

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
