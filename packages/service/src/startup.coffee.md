
# `nikita.service.startup`

Activate or desactivate a service on startup.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Indicates if the startup behavior has changed.   

## Example

```js
const {status} = await nikita.service.startup([{
  ssh: ssh,
  name: 'gmetad',
  startup: false
})
console.info(`Service was desactivated on startup: ${status}`)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.name = metadata.argument if typeof metadata.argument is 'string'

## Schema

    schema =
      type: 'object'
      properties:
        'arch_chroot':
          $ref: 'module://@nikitajs/engine/lib/actions/execute#/properties/arch_chroot'
        'name':
          $ref: 'module://@nikitajs/service/src/install#/properties/name'
        'rootdir':
          $ref: 'module://@nikitajs/engine/lib/actions/execute#/properties/rootdir'
        'startup':
          type: ['boolean', 'string']
          default: true
          description: """
          Run service daemon on startup, required. A string represent a list of
          activated levels, for example '2345' or 'multi-user'. An empty
          string to not define any run level. Note: String argument is only
          used if SysVinit runlevel is installed on the OS (automatically
          detected by nikita).
          """
      required: ['name']

## Handler

    handler = ({config, tools: {log}}) ->
      # log message: "Entering service.startup", level: 'DEBUG', module: 'nikita/lib/service/startup'
      config.startup = [config.startup] if Array.isArray config.startup
      # Action
      log message: "Startup service #{config.name}", level: 'INFO', module: 'nikita/lib/service/startup'
      unless config.command
        {stdout} = await @execute
          command: """
          if command -v systemctl >/dev/null 2>&1; then
            echo 'systemctl'
          elif command -v chkconfig >/dev/null 2>&1; then
            echo 'chkconfig'
          elif command -v update-rc.d >/dev/null 2>&1; then
            echo 'update-rc'
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
          """
          metadata: shy: true
        config.command = stdout.trim()
        throw Error "Unsupported Loader" unless config.command in ['systemctl', 'chkconfig', 'update-rc']
      if config.command is 'systemctl'
        try
          {status} = await @execute
            command: """
              startup=#{if config.startup then '1' else ''}
              if systemctl is-enabled #{config.name}; then
                [ -z "$startup" ] || exit 3
                echo 'Disable #{config.name}'
                systemctl disable #{config.name}
              else
                [ -z "$startup" ] && exit 3
                echo 'Enable #{config.name}'
                systemctl enable #{config.name}
              fi
              """
            trap: true
            code_skipped: 3
            arch_chroot: config.arch_chroot
            rootdir: config.rootdir
          message = if config.startup then 'activated' else 'disabled'
          log if status
          then message: "Service startup updated: #{message}", level: 'WARN', module: 'nikita/lib/service/remove'
          else message: "Service startup not modified: #{message}", level: 'INFO', module: 'nikita/lib/service/remove'
        catch err
          throw Error "Startup Enable Failed: #{config.name}" if config.startup
          throw Error "Startup Disable Failed: #{config.name}" if not config.startup
      if config.command is 'chkconfig'
        {status, stdout, stderr} = await @execute
          command: "chkconfig --list #{config.name}"
          code_skipped: 1
        # Invalid service name return code is 0 and message in stderr start by error
        if /^error/.test stderr
          log message: "Invalid chkconfig name for \"#{config.name}\"", level: 'ERROR', module: 'mecano/lib/service/startup'
          throw Error "Invalid chkconfig name for `#{config.name}`"
        current_startup = ''
        if status
          for c in stdout.split(' ').pop().trim().split '\t'
            [level, status] = c.split ':'
            current_startup += level if ['on', 'marche'].indexOf(status) > -1
        status = false if config.startup is true and current_startup.length
        status = false if config.startup is current_startup
        status = false if status and config.startup is false and current_startup is ''
        if config.startup
          command = "chkconfig --add #{config.name};"
          if typeof config.startup is 'string'
            startup_on = startup_off = ''
            for i in [0...6]
              if config.startup.indexOf(i) isnt -1
              then startup_on += i
              else startup_off += i
            command += "chkconfig --level #{startup_on} #{config.name} on;" if startup_on
            command += "chkconfig --level #{startup_off} #{config.name} off;" if startup_off
          else
            command += "chkconfig #{config.name} on;"
          await @execute
            command: command
          status = true
        unless config.startup
          log message: "Desactivating startup rules", level: 'DEBUG', module: 'mecano/lib/service/startup'
          log? "Mecano `service.startup`: s"
          # Setting the level to off. An alternative is to delete it: `chkconfig --del #{config.name}`
          await @execute
            command: "chkconfig #{config.name} off"
          status = true
        message = if config.startup then 'activated' else 'disabled'
        log if status
        then message: "Service startup updated: #{message}", level: 'WARN', module: 'nikita/lib/service/startup'
        else message: "Service startup not modified: #{message}", level: 'INFO', module: 'nikita/lib/service/startup'
      if config.command is 'update-rc'
        {status} = await @execute
          command: """
            startup=#{if config.startup then '1' else ''}
            if ls /etc/rc*.d/S??#{config.name}; then
              [ -z "$startup" ] || exit 3
              echo 'Disable #{config.name}'
              update-rc.d -f #{config.name} disable
            else
              [ -z "$startup" ] && exit 3
              echo 'Enable #{config.name}'
              update-rc.d -f #{config.name} enable
            fi
            """
          code_skipped: 3
          arch_chroot: config.arch_chroot
          rootdir: config.rootdir
        message = if config.startup then 'activated' else 'disabled'
        log if status
        then message: "Service startup updated: #{message}", level: 'WARN', module: 'nikita/lib/service/remove'
        else message: "Service startup not modified: #{message}", level: 'INFO', module: 'nikita/lib/service/remove'

## Export

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema
