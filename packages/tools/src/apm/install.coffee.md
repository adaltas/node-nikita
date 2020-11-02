
# `nikita.tools.apm`

Install Atom packages with APM.

## Options

*   `name` (string|array)
    Name of the package(s).
*   `upgrade` (boolean)
    Upgrade all packages, default to "false".

## Schema

    schema =
      type: 'object'
      properties:
        '':
          type: 'object'
          description: """
          """

## Handler

    handler = ({config}) ->
      config.name = config.argument if config.argument?
      config.name = [config.name] if typeof config.name is 'string'
      config.name = config.name.map (pkg) -> pkg.toLowerCase()
      outdated = []
      installed = []
      # Note, cant see a difference between update and upgrade after printing help
      @execute
        cmd: "apm outdated --json"
        shy: true
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        outdated = pkgs.map (pkg) -> pkg.name.toLowerCase()
      @execute
        cmd: "apm upgrade --no-confirm"
        if: -> config.upgrade and outdated.length
      , (err) ->
        throw err if err
        outdated = []
      @execute
        cmd: "apm list --installed --json"
        shy: true
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        pkgs = pkgs.user.map (pkg) -> pkg.name.toLowerCase()
        installed = pkgs
      @call ->
        upgrade = config.name.filter (pkg) -> pkg in outdated
        install = config.name.filter (pkg) -> pkg not in installed
        @execute
          cmd: "apm upgrade #{upgrade.join ' '}"
          if: upgrade.length
        , (err) =>
          @log message: "APM Updated Packages: #{upgrade.join ', '}"
        @execute
          cmd: "apm install #{install.join ' '}"
          if: install.length
        , (err) =>
          @log message: "APM Installed Packages: #{install.join ', '}"

## Exports

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
