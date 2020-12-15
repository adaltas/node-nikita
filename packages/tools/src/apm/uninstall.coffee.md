
# `nikita.tools.apm`

Remove one or more apm packages.

## Hooks

    on_action = ({config, metadata}) ->
      config.name = metadata.argument if typeof metadata.argument is 'string'
      config.name = [config.name] if typeof config.name is 'string'

## Schema

    schema =
      type: 'object'
      properties:
        'name':
          type: 'array', items: type: 'string'
          description: """
          Name of the package(s) to install.
          """

## Handler

    handler = ({config, tools: {log}}) ->
      config.name = config.name.map (pkg) -> pkg.toLowerCase()
      installed = []
      {stdout} = await @execute
        metadata: shy: true
        command: "apm list --installed --json"
      pkgs = JSON.parse stdout
      installed = pkgs.user.map (pkg) -> pkg.name.toLowerCase()
      # Uninstall
      uninstall = config.name.filter (pkg) -> pkg in installed
      if uninstall.length
        await @execute
          command: "apm uninstall #{config.name.join ' '}"
        log message: "APM Uninstalled Packages: #{config.name.join ', '}"

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema
