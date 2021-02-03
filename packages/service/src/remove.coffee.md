
# `nikita.service.remove`

Remove a package or service.

## Output

* `err`   
  Error object if any.   
* `status`   
  Indicates if the startup behavior has changed.   

## Example

```js
const {status} = await nikita.service.remove([{
  ssh: ssh,
  name: 'gmetad'
})
console.info(`Package or service was removed: ${status}`)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.name = metadata.argument if typeof metadata.argument is 'string'

## Schema

    schema =
      type: 'object'
      properties:
        'cache':
          type: 'boolean'
          description: """
          Run entirely from system cache to list installed and outdated
          packages.
          """
        'cacheonly':
          $ref: 'module://@nikitajs/service/src/install#/properties/cacheonly'
        'name':
          $ref: 'module://@nikitajs/service/src/install#/properties/name'
        # 'ssh':  # not supported
        #   type: 'object'
        #   description: """
        #   Run the action on a remote server using SSH, an ssh2 instance or an
        #   configuration object used to initialize the SSH connection.
        #   """
      required: ['name']

## Handler

    handler = ({config, parent: {state}, tools: {log}}) ->
      # config.manager ?= state['nikita:service:manager'] # not supported
      log message: "Remove service #{config.name}", level: 'INFO'
      cacheonly = if config.cacheonly then '-C' else ''
      if config.cache
        installed = state['nikita:execute:installed']
      unless installed?
        try
          {status, stdout} = await @execute
            command: """
            if command -v yum >/dev/null 2>&1; then
              rpm -qa --qf "%{NAME}\n"
            elif command -v pacman >/dev/null 2>&1; then
              pacman -Qqe
            elif command -v apt-get >/dev/null 2>&1; then
              dpkg -l | grep \'^ii\' | awk \'{print $2}\'
            else
              echo "Unsupported Package Manager" >&2
              exit 2
            fi
            """
            code_skipped: 1
            stdout_log: false
            metadata: shy: true
          if status
            log message: "Installed packages retrieved", level: 'INFO'
            installed = for pkg in utils.string.lines(stdout) then pkg
        catch err
          throw Error "Unsupported Package Manager" if err.exit_code is 2
      if installed.indexOf(config.name) isnt -1
        try
          {status} = await @execute
            command: """
            if command -v yum >/dev/null 2>&1; then
              yum remove -y #{cacheonly} '#{config.name}'
            elif command -v pacman >/dev/null 2>&1; then
              pacman --noconfirm -R #{config.name}
            elif command -v apt-get >/dev/null 2>&1; then
              apt-get remove -y #{config.name}
            else
              echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
              exit 2
            fi
            """
            code_skipped: 3
          # Update list of installed packages
          installed.splice installed.indexOf(config.name), 1
          # Log information
          log if status
          then message: "Service removed", level: 'WARN', module: 'nikita/lib/service/remove'
          else message: "Service already removed", level: 'INFO', module: 'nikita/lib/service/remove'
        catch err
          throw Error "Invalid Service Name: #{config.name}" if err
      if config.cache
        await @call
          handler: ->
            log message: "Caching installed on \"nikita:execute:installed\"", level: 'INFO'
            state['nikita:execute:installed'] = installed

## Export

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema

## Dependencies

    utils = require '@nikitajs/core/lib/utils'
