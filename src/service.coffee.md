
# `service(options, [goptions], callback)` 

Install a service. For now, only yum over SSH.

## Options

*   `name`   
    Package name, optional.   
*   `startup`   
    Run service daemon on startup. If true, startup will be set to '2345', use
    an empty string to not define any run level.   
*   `yum_name`   
    Name used by the yum utility, default to "name".   
*   `chk_name`   
    Name used by the chkconfig utility, default to "srv_name" and "name".   
*   `srv_name`   
    Name used by the service utility, default to "name".   
*   `cache`   
    Run entirely from system cache, run install and update checks offline.   
*   `action`   
    Execute the service with the provided action argument.   
*   `installed`   
    Cache a list of installed services. If an object, the service will be
    installed if a key of the same name exists; if anything else (default), no
    caching will take place.   
*   `updates`   
    Cache a list of outdated services. If an object, the service will be updated
    if a key of the same name exists; If true, the option will be converted to
    an object with all the outdated service names as keys; if anything else
    (default), no caching will take place.   
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
    Number of action taken (installed, updated, started or stopped).   
*   `installed`   
    List of installed services.   
*   `updates`   
    List of services to update.   

## Example

```js
require('mecano').service([{
  ssh: ssh,
  name: 'ganglia-gmetad-3.5.0-99',
  srv_name: 'gmetad',
  action: 'stop',
  startup: false
},{
  ssh: ssh,
  name: 'ganglia-web-3.5.7-99'
}], function(err, installed){
  console.log(err ? err.message : 'Service installed: ' + !!installed);
});
```

## Source Code

    module.exports = (options, callback) ->
      wrap @, arguments, (options, callback) ->
        installed = updates = null
        # Validate parameters
        # return callback new Error 'Missing service name' unless options.name
        return callback new Error 'Restricted to Yum over SSH' unless options.ssh
        # return callback new Error 'Invalid configuration, start conflict with stop' if options.start? and options.start is options.stop
        pkgname = options.yum_name or options.name
        chkname = options.chk_name or options.srv_name or options.name
        srvname = options.srv_name or options.chk_name or options.name
        # if options.startup? and typeof options.startup isnt 'string'
        #     options.startup = if options.startup then '2345' else ''
        modified = false
        installed ?= options.installed
        updates ?= options.updates
        options.action = options.action.split(',') if typeof options.action is 'string'
        # Start real work
        do_chkinstalled = ->
          # option name and yum_name are optional, skill installation if not present
          return do_startuped() unless pkgname
          cache = ->
            options.log? "Mecano `service: list installed [DEBUG]"
            c = if options.cache then '-C' else ''
            execute
              ssh: options.ssh
              cmd: "yum -C list installed"
              code_skipped: 1
              log: options.log
              # stdout: options.stdout
              # stderr: options.stderr
            , (err, executed, stdout) ->
              return callback err if err
              stdout = string.lines stdout
              start = false
              installed = []
              for pkg in stdout
                start = true if pkg.trim() is 'Installed Packages'
                continue unless start
                installed.push pkg[1] if pkg = /^([^\. ]+?)\./.exec pkg
              decide()
          decide = ->
            if installed.indexOf(pkgname) isnt -1 then do_chkupdates() else do_install()
          if installed then decide() else cache()
        do_chkupdates = ->
          cache = ->
            options.log? "Mecano `service`: list available updates [DEBUG]"
            c = if options.cache then '-C' else ''
            execute
              ssh: options.ssh
              cmd: "yum #{c} list updates"
              code_skipped: 1
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed, stdout) ->
              return callback err if err
              stdout = string.lines stdout
              start = false
              updates = []
              for pkg in stdout
                start = true if pkg.trim() is 'Updated Packages'
                continue unless start
                updates.push pkg[1] if pkg = /^([^\. ]+?)\./.exec pkg
              decide()
          decide = ->
            if updates.indexOf(pkgname) isnt -1 then do_install() else
              options.log? "Mecano `service`: No available update for '#{pkgname}' [INFO]"
              do_startuped()
          if updates then decide() else cache()
        do_install = ->
          options.log? "Mecano `service`: install '#{pkgname}' [INFO]"
          execute
            ssh: options.ssh
            cmd: "yum install -y #{pkgname}"
            # code_skipped: 1
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err, succeed) ->
            return callback err if err
            installedIndex = installed.indexOf pkgname
            installed.push pkgname if installedIndex is -1
            if updates
              updatesIndex = updates.indexOf pkgname
              updates.splice updatesIndex, 1 unless updatesIndex is -1
            # Those 2 lines seems all wrong
            unless succeed
              options.log? "Mecano `service`: No package available for '#{pkgname}' [ERROR]"
              return callback new Error "No package available for '#{pkgname}'."
            modified = true if installedIndex isnt -1
            do_startuped()
        do_startuped = ->
          return do_started() unless options.startup?
          options.log? "Mecano `service`: list startup services [DEBUG]"
          execute
            ssh: options.ssh
            cmd: "chkconfig --list #{chkname}"
            code_skipped: 1
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err, registered, stdout, stderr) ->
            return callback err if err
            # Invalid service name return code is 0 and message in stderr start by error
            if /^error/.test stderr
              options.log? "Mecano `service`: Invalid chkconfig name for `#{chkname}` [ERROR]"
              return callback new Error "Invalid chkconfig name for `#{chkname}`"
            current_startup = ''
            if registered
              for c in stdout.split(' ').pop().trim().split '\t'
                [level, status] = c.split ':'
                current_startup += level if ['on', 'marche'].indexOf(status) > -1
            return do_started() if (options.startup is true and current_startup.length) or (options.startup is current_startup)
            return do_started() if registered and options.startup is false and current_startup is ''
            modified = true
            if options.startup
            then startup_add()
            else startup_del()
        startup_add = ->
          options.log? "Mecano `service`: startup on"
          cmd = "chkconfig --add #{chkname};"
          if typeof options.startup is 'string'
            startup_on = startup_off = ''
            for i in [0...6]
              if options.startup.indexOf(i) isnt -1
              then startup_on += i
              else startup_off += i
            cmd += "chkconfig --level #{startup_on} #{chkname} on;" if startup_on
            cmd += "chkconfig --level #{startup_off} #{chkname} off;" if startup_off
          else
            cmd += "chkconfig #{chkname} on;"
          execute
            ssh: options.ssh
            cmd: cmd
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err) ->
            return callback err if err
            do_started()
        startup_del = ->
          options.log? "Mecano `service`: startup off"
          # Note, we are deleting the service but instead we could
          # make sure it's added but in "off" state.
          execute
            ssh: options.ssh
            # cmd: "chkconfig --del #{chkname}"
            cmd: "chkconfig #{chkname} off"
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err) ->
            return callback err if err
            do_started()
        do_started = ->
          return do_finish() unless options.action
          options.log? "Mecano `service`: check if started"
          execute
            ssh: options.ssh
            cmd: "service #{srvname} status"
            code_skipped: [3, 1] # ntpd return 1 if pidfile exists without a matching process
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err, started) ->
            return callback err if err
            if started
              return do_action 'stop' if 'stop' in options.action
              return do_action 'restart' if 'restart' in options.action
            else
              return do_action 'start' if 'start' in options.action
            do_finish()
        do_action = (action) ->
          return do_finish() unless options.action
          options.log? "Mecano `service`: #{action} service"
          execute
            ssh: options.ssh
            cmd: "service #{srvname} #{action}"
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err, executed) ->
            return callback err if err
            modified = true
            do_finish()
        do_finish = ->
          callback null, modified
        do_chkinstalled()

## Dependencies

    each = require 'each'
    execute = require './execute'
    misc = require './misc'
    string = require './misc/string'
    wrap = require './misc/wrap'






