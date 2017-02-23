
# `mecano.service.startup(options, [callback])`

Activate or desactivate a service on startup.

## Options

*   `name` (string)   
    Service name, required.   
*   `startup` (boolean|string)
    Run service daemon on startup, required. A string represent a list of activated
    levels, for example '2345' or 'multi-user'.   
    An empty string to not define any run level.   
    Note: String argument is only used if SysVinit runlevel is installed on 
    the OS (automatically detected by mecano).   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Indicates if the startup behavior has changed.   

## Example

```js
require('mecano').service.startup([{
  ssh: ssh,
  name: 'gmetad',
  startup: false
}, function(err, modified){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.startup", level: 'DEBUG', module: 'mecano/lib/service/startup'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      options.startup ?= true
      options.startup = [options.startup] if Array.isArray options.startup
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name?
      # Action
      options.log message: "Startup service #{options.name}", level: 'INFO', module: 'mecano/lib/service/startup'
      modified = false
      @call discover.loader, -> options.loader ?= options.store['mecano:service:loader']
      @call
        if: -> options.loader is 'service'
        handler: ->
          do_enable = false
          do_disable = false
          @call 
            shy: true
            handler: (_, callback) ->
              @system.execute
                cmd: "chkconfig --list #{options.name}"
                shy: true
                code_skipped: 1
              , (err, registered, stdout, stderr) ->
                return callback err if err
                # Invalid service name return code is 0 and message in stderr start by error
                if /^error/.test stderr
                  options.log message: "Invalid chkconfig name for \"#{options.name}\"", level: 'ERROR', module: 'mecano/service/startup'
                  return callback new Error "Invalid chkconfig name for `#{options.name}`"
                current_startup = ''
                if registered
                  for c in stdout.split(' ').pop().trim().split '\t'
                    [level, status] = c.split ':'
                    current_startup += level if ['on', 'marche'].indexOf(status) > -1
                istr = typeof options.startup is 'string'
                startup = if istr then true else options.startup
                if startup
                  do_enable = (current_startup.length is 0) or  (if istr then (options.startup isnt current_startup) else false)
                else
                  do_disable = registered and current_startup.length isnt 0
                callback null, false
          @call 
            if: -> do_enable and not @status -1
            handler: ->
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
              , (err) ->
                throw err if err
                options.log message: "Startup rules modified", level: 'INFO', module: 'mecano/service/startup'
          @call 
            if: -> do_disable and not do_enable
            handler: ->
              options.log message: "Desactivating startup rules", level: 'DEBUG', module: 'mecano/service/startup'
              # Setting the level to off. An alternative is to delete it: `chkconfig --del #{options.name}`
              @system.execute
                cmd: "chkconfig #{options.name} off"
              , (err, disabled, stdout, stderr) ->
                throw err if err
                options.log message: "Startup rules desactivating", level: 'INFO', module: 'mecano/service/startup'
      @call
        if: -> options.loader is 'systemctl'
        handler: ->
          @system.execute
            shy: true
            cmd: "systemctl is-enabled #{options.name}"
            code_skipped: 1
          @system.execute
            if: -> (not @status(-1)) and options.startup
            cmd: "systemctl enable #{options.name}"
          @system.execute
            if: -> @status(-2) and (not options.startup)
            cmd: "systemctl disable #{options.name}"

## Dependencies
    
    discover = require '../misc/discover'
