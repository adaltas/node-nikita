
# `nikita.service.init`

Render startup script.
Reload the service daemon provider depending on the os.

## Output

* `err`   
  Error object if any.
* `status`   
  Indicates if the init script was reloaded.

## Schema

    schema =
      type: 'object'
      properties:
        'backup':
          $ref: 'module://@nikitajs/file/lib/index#/properties/backup'
        'context':
          $ref: 'module://@nikitajs/file/lib/index#/properties/context'
          default: {}
          description: """
          The context object used to render the scripts file; templating is
          disabled if no context is provided.
          """
        'engine':
          $ref: 'module://@nikitajs/file/lib/index#/properties/engine'
        'filters':
          typeof: 'function'
          description: """
          Filter function to extend the nunjucks engine.
          """
        'gid':
          $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/properties/gid'
        'local':
          $ref: 'module://@nikitajs/file/lib/index#/properties/local'
        'mode':
          default: '0o755'
          $ref: 'module://@nikitajs/core/lib/actions/fs/chmod#/properties/mode'
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
          $ref: 'module://@nikitajs/file/lib/index#/properties/source'
        'target':
          $ref: 'module://@nikitajs/file/lib/index#/properties/target'
          description: """
          The destination file. `/etc/init.d/crond` or
          `/etc/systemd/system/crond.service` for example. If no provided,
          nikita put it on the default folder based on the service daemon
          provider,the OS and use the source filename as the name.
          """
        'uid':
          $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/properties/uid'
      required: ['source']
## Handler

    handler = ({config, tools: {path}}) ->
      # check if file is target is directory
      # detect daemon loader provider to construct target
      config.name ?= path.basename(config.source).split('.')[0]
      config.name = path.basename(config.target).split('.service')[0] if config.target?
      config.target ?= "/etc/init.d/#{config.name}"
      {loader} = await @service.discover {}
      config.loader ?= loader
      # discover loader to put in cache
      await @file.render
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
        metadata: shy: true
        command: """
          systemctl status #{config.name} 2>\&1 | egrep \
          '(Reason: No such file or directory)|(Unit #{config.name}.service could not be found)|(#{config.name}.service changed on disk)'
          """
        code_skipped: 1
      return unless status
      await @execute
        command: 'systemctl daemon-reload;systemctl reset-failed'

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema

[sysvinit vs systemd]:(https://www.digitalocean.com/community/tutorials/how-to-configure-a-linux-service-to-start-automatically-after-a-crash-or-reboot-part-2-reference)
