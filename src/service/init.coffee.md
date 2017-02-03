
# `mecano.service.init(options, [callback])`

Render startup script.
Reload the service daemon provider depending on the os.

## Options

*   `context` (object)   
    The context object used to render the scripts file
*   `engine`   
    Template engine to use. Nunjucks by default   
*   `filters` (function)   
    Filter function to extend the nunjucks engine.   
*   `local`   
    Treat the source as local instead of remote, only apply with "ssh"
    option.   
*   `name` (string)   
    The name of the destination file. Use the name of the template if missing.
*   `skip_empty_lines`   
    Remove empty lines.   
*   `source` (boolean) REQUIRED   
    The source of startup script template.   
*   `target` (string) OPTIONAL   
    The destination file. `/etc/init.d/crond` or `/etc/systemd/system/crond.service` for example.
    If no provided, mecano put it on the default folder based on the service daemon
    provider,the OS and use the source filename as the name.
*   `uid`   
    File user name or user id.   
*   `gid`   
    File group name or group id.   
*   `mode`   
    File mode (permission and sticky bits), default to `0666`, in the for of
    `{mode: 0o744}` or `{mode: "744"}`.   

## Source Code
    
    module.exports = (options) ->
      options.log message: "Entering service.init", level: 'DEBUG', module: 'mecano/lib/service/init'
      # mandatory options
      throw Error 'Missing source' unless options.source?
      options.engine ?= 'nunjunks'
      options.mode ?= 0o755
      # check if file is target is directory
      # detect daemon loader provider to construct target
      options.name ?= path.basename(options.source).split('.')[0]
      options.target ?= "/etc/init.d/#{options.name}"
      @call discover.loader, options
      # discover loader to put in cache
      @call discover.system
      @call discover.loader, -> options.loader ?= options.store['mecano:service:loader']
      @call ->
        cmd = "systemctl status #{options.name} 2>\&1 "
        if options.store['mecano:system:type'] in ['redhat','centos'] and options.loader is 'systemctl'
          cmd += switch options.store['mecano:system:release'].split('.')[1]
            when '1' then "| grep '(Reason: No such file or directory)'"
            when '2' then "| grep 'Unit #{options.name}.service could not be found.'"
            when '3' then "| grep 'Unit #{options.name}.service could not be found.'"
        @render 
          target: options.target
          source: options.source
          mode: options.mode
          uid: options.uid
          gid: options.gid
          backup: options.backup
          context: options.context
          local: options.local
        @execute
          if: -> (options.loader is 'systemctl') and (path.dirname(options.target) is '/etc/init.d')
          shy: true
          cmd: cmd
          code_skipped: 1
        @execute
          if: ->  @status(-1)
          cmd: 'systemctl daemon-reload'

## Dependencies
    
    fs = require 'ssh2-fs'
    path = require 'path'
    discover = require '../misc/discover'

[sysvinit vs systemd]:(https://www.digitalocean.com/community/tutorials/how-to-configure-a-linux-service-to-start-automatically-after-a-crash-or-reboot-part-2-reference)
