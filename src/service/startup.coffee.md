
# `nikita.service.startup`

Activate or desactivate a service on startup.

## Options

* `arch_chroot` (boolean|string)   
  Run this command inside a root directory with the arc-chroot command or any 
  provided string, require the "rootdir" option if activated.   
* `rootdir` (string)   
  Path to the mount point corresponding to the root directory, required if 
  the "arch_chroot" option is activated.   
* `cache` (boolean)   
  Cache service information.   
* `name` (string)   
  Service name, required.   
* `startup` (boolean|string)
  Run service daemon on startup, required. A string represent a list of activated
  levels, for example '2345' or 'multi-user'.   
  An empty string to not define any run level.   
  Note: String argument is only used if SysVinit runlevel is installed on 
  the OS (automatically detected by nikita).   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Indicates if the startup behavior has changed.   

## Example

```js
require('nikita')
.service.startup([{
  ssh: ssh,
  name: 'gmetad',
  startup: false
}, function(err, modified){ /* do sth */ });
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering service.startup", level: 'DEBUG', module: 'nikita/lib/service/startup'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      options.startup ?= true
      options.startup = [options.startup] if Array.isArray options.startup
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name?
      # Action
      @log message: "Startup service #{options.name}", level: 'INFO', module: 'nikita/lib/service/startup'
      @system.execute
        unless: options.cmd
        cmd: """
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
        shy: true
      , (err, {stdout}) ->
        throw err if err
        options.cmd = stdout.trim()
        throw Error "Unsupported Loader" unless options.cmd in ['systemctl', 'chkconfig', 'update-rc']
      @system.execute
        if: -> options.cmd is 'systemctl'
        cmd: """
          startup=#{if options.startup then '1' else ''}
          if systemctl is-enabled #{options.name}; then
            [ -z "$startup" ] || exit 3
            echo 'Disable #{options.name}'
            systemctl disable #{options.name}
          else
            [ -z "$startup" ] && exit 3
            echo 'Enable #{options.name}'
            systemctl enable #{options.name}
          fi
          """
        trap: true
        code_skipped: 3
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
      , (err, {status}) ->
        err = Error "Startup Enable Failed: #{options.name}" if err and options.startup
        err = Error "Startup Disable Failed: #{options.name}" if err and not options.startup
        throw err if err
        message = if options.startup then 'activated' else 'disabled'
        @log if status
        then message: "Service startup updated: #{message}", level: 'WARN', module: 'nikita/lib/service/remove'
        else message: "Service startup not modified: #{message}", level: 'INFO', module: 'nikita/lib/service/remove'
      @call
        if: -> options.cmd is 'chkconfig'
      , (_, callback) ->
        @system.execute
          if: -> options.cmd is 'chkconfig'
          cmd: "chkconfig --list #{options.name}"
          code_skipped: 1
        , (err, {status, stdout, stderr}) ->
          return callback err if err
          # Invalid service name return code is 0 and message in stderr start by error
          if /^error/.test stderr
            @log message: "Invalid chkconfig name for \"#{options.name}\"", level: 'ERROR', module: 'mecano/lib/service/startup'
            throw Error "Invalid chkconfig name for `#{options.name}`"
          current_startup = ''
          if status
            for c in stdout.split(' ').pop().trim().split '\t'
              [level, status] = c.split ':'
              current_startup += level if ['on', 'marche'].indexOf(status) > -1
          return callback() if options.startup is true and current_startup.length
          return callback() if options.startup is current_startup
          return callback() if status and options.startup is false and current_startup is ''
          @call if: options.startup, ->
            cmd = "chkconfig --add #{options.name};"
            if typeof options.startup is 'string'
              startup_on = startup_off = ''
              for i in [0...6]
                if options.startup.indexOf(i) isnt -1
                then startup_on += i
                else startup_off += i
              cmd += "chkconfig --level #{startup_on} #{options.name} on;" if startup_on
              cmd += "chkconfig --level #{startup_off} #{options.name} off;" if startup_off
            else
              cmd += "chkconfig #{options.name} on;"
            @system.execute
              cmd: cmd
            , (err) -> callback err, true
          @call unless: options.startup, ->
            @log message: "Desactivating startup rules", level: 'DEBUG', module: 'mecano/lib/service/startup'
            @log? "Mecano `service.startup`: s"
            # Setting the level to off. An alternative is to delete it: `chkconfig --del #{options.name}`
            @system.execute
              cmd: "chkconfig #{options.name} off"
            , (err) -> callback err, true
      , (err, status) ->
        throw err if err
        message = if options.startup then 'activated' else 'disabled'
        @log if status
        then message: "Service startup updated: #{message}", level: 'WARN', module: 'nikita/lib/service/startup'
        else message: "Service startup not modified: #{message}", level: 'INFO', module: 'nikita/lib/service/startup'
      @system.execute
        if: -> options.cmd is 'update-rc'
        cmd: """
          startup=#{if options.startup then '1' else ''}
          if ls /etc/rc*.d/S??#{options.name}; then
            [ -z "$startup" ] || exit 3
            echo 'Disable #{options.name}'
            update-rc.d -f #{options.name} disable
          else
            [ -z "$startup" ] && exit 3
            echo 'Enable #{options.name}'
            update-rc.d -f #{options.name} enable
          fi
          """
        code_skipped: 3
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
      , (err, {status}) ->
        throw err if err
        message = if options.startup then 'activated' else 'disabled'
        @log if status
        then message: "Service startup updated: #{message}", level: 'WARN', module: 'nikita/lib/service/remove'
        else message: "Service startup not modified: #{message}", level: 'INFO', module: 'nikita/lib/service/remove'
