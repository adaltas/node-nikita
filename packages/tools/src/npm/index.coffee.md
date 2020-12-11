
# `nikita.tools.npm`

Install Node.js packages with NPM.

It upgrades outdated packages if config "upgrade" is "true".

## Example

The following action installs the coffescript package globally.

```js
const {status} = await nikita.tools.npm({
  name: 'coffeescript',
  global: true
})
console.info(`Package was installed: ${status}`)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.name = metadata.argument if typeof metadata.argument is 'string'
      config.name = [config.name] if typeof config.name is 'string'

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
          Installs the current package context as a global package.
          """
        'name':
          type: 'array', items: type: 'string'
          description: """
          Name of the package(s) to install or upgrade if config "upgrade" is
          "true".
          """
        'sudo':
          $ref: 'module://@nikitajs/engine/src/actions/execute#/properties/sudo'
        'upgrade':
          default: false
          type: 'boolean'
          description: """
          Upgrade outdated packages.
          """
      required: ['name']
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
        metadata: shy: true
      pkgs = JSON.parse stdout
      outdated = Object.keys pkgs if Object.keys(pkgs).length
      # Upgrade outdated packages
      upgrade = config.name.filter (pkg) -> pkg in outdated
      if config.upgrade and upgrade.length
        await @execute
          command: "npm update #{global} #{upgrade.join ' '}"
          cwd: config.cwd
          sudo: config.sudo
        log message: "NPM Updated Packages: #{upgrade.join ', '}"
      # Get installed packages
      installed = []
      {stdout} = await @execute
        command: "npm list --json #{global}"
        code: [0, 1]
        cwd: config.cwd
        stdout_log: false
        metadata: shy: true
      pkgs = JSON.parse stdout
      installed = Object.keys pkgs.dependencies if Object.keys(pkgs).length
      # Install packages
      install = config.name.filter (pkg) -> pkg not in installed
      return unless install.length
      await @execute
        command: "npm install #{global} #{install.join ' '}"
        cwd: config.cwd
        sudo: config.sudo
      log message: "NPM Installed Packages: #{install.join ', '}"

## Export

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema
