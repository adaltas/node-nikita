
# `nikita.service.init`

Render startup script.
Reload the service daemon provider depending on the os.

## Options

* `backup` (string|boolean, optional)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `context` (object, optional)   
  The context object used to render the scripts file; templating is disabled if
  no context is provided.
* `engine` (string, optional, "nunjunks")   
  Template engine to use; Nunjucks by default.
* `filters` (function)   
  Filter function to extend the nunjucks engine.
* `local`   
  Treat the source as local instead of remote, only apply with "ssh"
  option.
* `name` (string)   
  The name of the destination file. Use the name of the template if missing.
* `skip_empty_lines`   
  Remove empty lines.
* `source` (boolean) REQUIRED   
  The source of startup script template.
* `target` (string) OPTIONAL   
  The destination file. `/etc/init.d/crond` or `/etc/systemd/system/crond.service` for example.
  If no provided, nikita put it on the default folder based on the service daemon
  provider,the OS and use the source filename as the name.
* `uid`   
  File user name or user id.
* `gid`   
  File group name or group id.
* `mode`   
  File mode (permission and sticky bits), default to `0666`, in the for of
  `{mode: 0o744}` or `{mode: "744"}`.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  Indicates if the init script was reloaded.

## Source Code
    
    module.exports = ({options}) ->
      @log message: "Entering service.init", level: 'DEBUG', module: 'nikita/lib/service/init'
      # mandatory options
      throw Error 'Missing source' unless options.source?
      options.engine ?= 'nunjunks'
      options.mode ?= 0o755
      # check if file is target is directory
      # detect daemon loader provider to construct target
      options.name ?= path.basename(options.source).split('.')[0]
      options.name = path.basename(options.target).split('.service')[0] if options.target?
      options.target ?= "/etc/init.d/#{options.name}"
      options.context ?= null
      @service.discover (err, system) ->
        options.loader ?= system.loader
      # discover loader to put in cache
        @file.render
          if: options.context?
          target: options.target
          source: options.source
          mode: options.mode
          uid: options.uid
          gid: options.gid
          backup: options.backup
          context: options.context
          local: options.local
        @system.execute
          if: -> options.loader is 'systemctl'
          shy: true
          cmd: """
            systemctl status #{options.name} 2>\&1 | egrep \
            '(Reason: No such file or directory)|(Unit #{options.name}.service could not be found)|(#{options.name}.service changed on disk)'
            """
          code_skipped: 1
        @system.execute
          if: ->  @status -1
          cmd: 'systemctl daemon-reload;systemctl reset-failed'

## Dependencies

    path = require 'path'

[sysvinit vs systemd]:(https://www.digitalocean.com/community/tutorials/how-to-configure-a-linux-service-to-start-automatically-after-a-crash-or-reboot-part-2-reference)
