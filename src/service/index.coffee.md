
# `service(options, callback)`

Install a service. For now, only yum over SSH.

## Options

*   `name` (string)   
    Package name, optional.   
*   `startup`   
    Run service daemon on startup. If true, startup will be set to '2345', use
    an empty string to not define any run level.   
*   `yum_name` (string)   
    Name used by the yum utility, default to "name".   
*   `chk_name` (string)   
    Name used by the chkconfig utility, default to "srv_name" and "name".   
*   `srv_name` (string)   
    Name used by the service utility, default to "name".   
*   `cache`   
    Run entirely from system cache to list installed and outdated packages.   
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
      installed = updates = null
      # Validate parameters
      # return callback new Error 'Missing service name' unless options.name
      # return callback new Error 'Restricted to Yum over SSH' unless options.ssh
      # return callback new Error 'Invalid configuration, start conflict with stop' if options.start? and options.start is options.stop
      pkgname = options.yum_name or options.name
      chkname = options.chk_name or options.srv_name or options.name
      srvname = options.srv_name or options.chk_name or options.name
      modified = false
      if options.cache
        installed = options.store['mecano:execute:installed']
        updates = options.store['mecano:execute:updates']
      options.action = options.action.split(',') if typeof options.action is 'string'
      # Start real work
      do_installed = =>
        # option name and yum_name are optional, skill installation if not present
        return do_startuped() unless pkgname
        cache = =>
          options.log message: "List installed", level: 'DEBUG', module: 'mecano/service/index'
          c = if options.cache then '-C' else ''
          @execute
            ssh: options.ssh
            cmd: "yum #{c} list installed"
            code_skipped: 1
            stdout: null
            stderr: null
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
          if installed.indexOf(pkgname) isnt -1 then do_updates() else do_install()
        if installed then decide() else cache()
      do_updates = =>
        cache = =>
          options.log message: "List available updates", level: 'DEBUG', module: 'mecano/service/index'
          c = if options.cache then '-C' else ''
          @execute
            cmd: "yum #{c} list updates"
            code_skipped: 1
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
            options.log message: "No available update for \"#{pkgname}\"", level: 'INFO', module: 'mecano/service/index'
            do_startuped()
        if updates then decide() else cache()
      do_install = =>
        options.log message: "Install \"#{pkgname}\"", level: 'INFO', module: 'mecano/service/index'
        @execute
          ssh: options.ssh
          cmd: "yum install -y #{pkgname}"
        , (err, succeed) ->
          return callback err if err
          installedIndex = installed.indexOf pkgname
          installed.push pkgname if installedIndex is -1
          if updates
            updatesIndex = updates.indexOf pkgname
            updates.splice updatesIndex, 1 unless updatesIndex is -1
          # Those 2 lines seems all wrong
          unless succeed
            options.log message: "No package available for \"#{pkgname}\"", level: 'ERROR', module: 'mecano/service/index'
            return callback new Error "No package available for '#{pkgname}'."
          modified = true if installedIndex isnt -1
          do_startuped()
      do_startuped = =>
        return do_started() unless options.startup?
        @service_startup
          name: chkname
          startup: options.startup
          if: options.startup?
        , (err, startuped) ->
          return callback err if err
          modified = startuped
          do_started()
      do_started = =>
        return do_finish() unless options.action
        options.log message: "Check if started", level: 'DEBUG', module: 'mecano/service/index'
        @service_status
          name: srvname
          code_started: options.code_started
          code_stopped: options.code_stopped
        , (err, started) ->
          return callback err if err
          if started
            return do_action 'stop' if 'stop' in options.action
            return do_action 'restart' if 'restart' in options.action
          else
            return do_action 'start' if 'start' in options.action
          do_finish()
      do_action = (action) =>
        return do_finish() unless options.action
        options.log message: "Running #{action} on service", level: 'INFO', module: 'mecano/service/index'
        @["service_#{action}"]
          name: srvname
          code_started: options.code_started
          code_stopped: options.code_stopped
        , (err, executed) ->
          return callback err if err
          modified = true
          do_finish()
      do_finish = ->
        if options.cache
          options.log message: "Caching installed on \"mecano:execute:installed\"", level: 'INFO', module: 'mecano/service/index'
          options.store['mecano:execute:installed'] = installed
          options.log message: "Caching updates on \"mecano:execute:updates\"", level: 'INFO', module: 'mecano/service/index'
          options.store['mecano:execute:updates'] = updates
        callback null, modified
      do_installed()

## Dependencies

    service_startup = require './startup'
    string = require '../misc/string'
