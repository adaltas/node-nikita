
# `nikita.tools.apm`

Remove one or more apm packages.

## Options

* `name` (string|array, required)
  Name of the package(s).

## Source code

    handler = ({options}) ->
      options.name = options.argument if options.argument?
      options.name = [options.name] if typeof options.name is 'string'
      options.name = options.name.map (pkg) -> pkg.toLowerCase()
      installed = []
      @system.execute
        shy: true
        cmd: "apm list --installed --json"
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        pkgs = pkgs.user.map (pkg) -> pkg.name.toLowerCase()
        installed = pkgs
      @call ->
        to_uninstall = options.name.filter (pkg) -> pkg in installed
        @system.execute
          cmd: "apm uninstall #{options.name.join ' '}"
          if: to_uninstall.length
        , (err) =>
          @log message: "APM Uninstalled Packages: #{options.name.join ', '}"

## Exports

    module.exports =
      handler: handler

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
