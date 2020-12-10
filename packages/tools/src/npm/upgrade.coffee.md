
# `nikita.tools.npm.upgrade`

Upgrade all Node.js packages with NPM.

## Example

The following action upgrades all global packages.

```js
const {status} = await nikita.tools.npm.upgrade({
  global: true
})
console.info(`Packages were upgraded: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        'cwd':
          $ref: 'module://@nikitajs/engine/src/actions/execute#/properties/cwd'
        'global':
          type: 'boolean'
          default: false
          description: """
          Upgrades global packages.
          """
        'sudo':
          $ref: 'module://@nikitajs/engine/src/actions/execute#/properties/sudo'
      if: properties: 'global': const: false
      then: required: ['cwd']

## Handler

    handler = ({config, tools: {log}}) ->
      global = if config.global then '-g' else ''
      # Get outdated packages
      outdated = []
      {stdout} = await @execute
        command: "npm outdated --json #{global}"
        code: [0, 1]
        cwd: config.cwd
        stdout_log: false
        shy: true
      pkgs = JSON.parse stdout
      outdated = Object.keys pkgs if Object.keys(pkgs).length
      # Upgrade outdated packages
      return unless outdated.length
      await @execute
        command: "npm update #{global}"
        cwd: config.cwd
        sudo: config.sudo
      log message: "NPM upgraded packages: #{outdated.join ', '}"

## Export

    module.exports =
      handler: handler
      schema: schema
