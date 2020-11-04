
# `nikita.service.init`

Render startup script.
Reload the service daemon provider depending on the os.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  Indicates if the init script was reloaded.

## Schema

    schema =
      type: 'object'
      properties:
        'backup':
          $ref: 'module://@nikitajs/file/src/index#/properties/backup'
        'context':
          $ref: 'module://@nikitajs/file/src/index#/properties/context'
          default: {}
          description: """
          The context object used to render the scripts file; templating is
          disabled if no context is provided.
          """
        'engine':
          $ref: 'module://@nikitajs/file/src/index#/properties/engine'
          default: 'nunjunks'
        'filters':
          typeof: 'function'
          description: """
          Filter function to extend the nunjucks engine.
          """
        'local':
          $ref: 'module://@nikitajs/file/src/index#/properties/local'
        'name':
          type: 'string'
          description: """
          The name of the destination file. Uses the name of the template if
          missing.
          """
        # 'skip_empty_lines': # not supported
        #   type: 'boolean'
        #   description: """
        #   Remove empty lines.
        #   """
        'source':
          $ref: 'module://@nikitajs/file/src/index#/properties/source'
        'target':
          $ref: 'module://@nikitajs/file/src/index#/properties/target'
          description: """
          The destination file. `/etc/init.d/crond` or
          `/etc/systemd/system/crond.service` for example. If no provided,
          nikita put it on the default folder based on the service daemon
          provider,the OS and use the source filename as the name.
          """
        'uid':
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chown#/properties/uid'
        'gid':
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chown#/properties/gid'
        'mode':
          default: '0o755'
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chmod#/properties/mode'
      required: ['source']
## Handler

    handler = ({config, tools: {path}}) ->
      # log message: "Entering service.init", level: 'DEBUG', module: 'nikita/lib/service/init'
      # check if file is target is directory
      # detect daemon loader provider to construct target
      config.name ?= path.basename(config.source).split('.')[0]
      config.name = path.basename(config.target).split('.service')[0] if config.target?
      config.target ?= "/etc/init.d/#{config.name}"
      {loader} = await @service.discover {}
      config.loader ?= loader
      # discover loader to put in cache
      @file.render
        target: config.target
        source: config.source
        mode: config.mode
        uid: config.uid
        gid: config.gid
        backup: config.backup
        context: config.context
        local: config.local
        engine: config.engine
      return unless config.loader is 'systemctl'
      {status} = await @execute
        shy: true
        cmd: """
          systemctl status #{config.name} 2>\&1 | egrep \
          '(Reason: No such file or directory)|(Unit #{config.name}.service could not be found)|(#{config.name}.service changed on disk)'
          """
        code_skipped: 1
      return unless status
      @execute
        cmd: 'systemctl daemon-reload;systemctl reset-failed'

## Export

    module.exports =
      handler: handler
      schema: schema

[sysvinit vs systemd]:(https://www.digitalocean.com/community/tutorials/how-to-configure-a-linux-service-to-start-automatically-after-a-crash-or-reboot-part-2-reference)
