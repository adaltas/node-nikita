
# `nikita.tools.npm`

Install Node.js packages with NPM.

## Options

* `name` (string|array, required)
  Name of the package(s).
* `global` (boolean)
  Installs the current package context as a global package.
* `upgrade` (boolean)
  Upgrade all packages, defaults to "false".

## Callback Parameters

* `err`
  Error object if any.
* `status`
  Value "true" if the package was installed.

## Example

The following action installs the coffescript package globally.

```javascript
require('nikita')
.tools.npm({
  name: 'coffeescript',
  global: true
}, (err, {status}) => {
  console.log(err ? err.message : 'Package installed ' + status);
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
          description: 'Installs the current package context as a global package.'
        'upgrade': 
          type: 'boolean'
          default: false
          description: 'Upgrade all packages, defaults to "false".'
      required: ['name']

## Handler

    handler = ({options}, callback) ->
      options.name = options.argument if options.argument?
      options.name = [options.name] if typeof options.name is 'string'
      global = if options.global then ' -g' else ''
      outdated = []
      installed = []
      # Note, cant see a difference between update and upgrade after printing help
      @system.execute
        cmd: "npm list --outdated --json #{global}"
        code: [0, 1]
        stdout_log: false
        shy: true
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        outdated = Object.keys pkgs.dependencies
      @system.execute
        if: -> options.upgrade and outdated.length
        cmd: "npm update"
      , (err) ->
        throw err if err
        outdated = []
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
        upgrade = options.name.filter (pkg) -> pkg in outdated
        install = options.name.filter (pkg) -> pkg not in installed
        @system.execute
          if: upgrade.length
          cmd: "npm update #{global} #{upgrade.join ' '}"
          sudo: options.sudo
        , (err) =>
          @log message: "NPM Updated Packages: #{upgrade.join ', '}"
        @system.execute
          if: install.length
          cmd: "npm install #{global} #{install.join ' '}"
          sudo: options.sudo
        , (err) =>
          @log message: "NPM Installed Packages: #{install.join ', '}"

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
