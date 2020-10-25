
# `nikita.tools.apm`

Remove one or more apm packages.

## Options

* `name` (string|array, required)
  Name of the package(s).

## Source code

    handler = ({config}) ->
      config.name = config.argument if config.argument?
      config.name = [config.name] if typeof config.name is 'string'
      config.name = config.name.map (pkg) -> pkg.toLowerCase()
      installed = []
      @execute
        shy: true
        cmd: "apm list --installed --json"
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        pkgs = pkgs.user.map (pkg) -> pkg.name.toLowerCase()
        installed = pkgs
      @call ->
        to_uninstall = config.name.filter (pkg) -> pkg in installed
        @execute
          cmd: "apm uninstall #{config.name.join ' '}"
          if: to_uninstall.length
        , (err) =>
          @log message: "APM Uninstalled Packages: #{config.name.join ', '}"

## Exports

    module.exports =
      handler: handler

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
