
# `nikita.service.remove(options, [callback])`

Status of a service.

## Options

* `cacheonly` (boolean)   
  Run the yum command entirely from system cache, don't update cache.   
* `name` (string)   
  Service name.   
* `ssh` (object|ssh2)   
  Run the action on a remote server using SSH, an ssh2 instance or an
  configuration object used to initialize the SSH connection.   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Indicates if the startup behavior has changed.   

## Example

```js
require('nikita').service.start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      @log message: "Entering service.remove", level: 'DEBUG', module: 'nikita/lib/service/remove'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      options.manager ?= @store['nikita:service:manager']
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      @log message: "Remove service #{options.name}", level: 'INFO', module: 'nikita/lib/service/remove'
      cacheonly = if options.cacheonly then '-C' else ''
      if options.cache
        installed = @store['nikita:execute:installed']
      @system.execute
        cmd: """
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
        shy: true
        unless: installed?
      , (err, {status, stdout}) ->
        throw Error "Unsupported Package Manager" if err?.code is 2
        throw err if err
        return unless status
        @log message: "Installed packages retrieved", level: 'INFO', module: 'nikita/lib/service/remove'
        installed = for pkg in string.lines(stdout) then pkg
      @system.execute
        cmd: """
        if command -v yum >/dev/null 2>&1; then
          yum remove -y #{cacheonly} '#{options.name}'
        elif command -v pacman >/dev/null 2>&1; then
          pacman --noconfirm -R #{options.name}
        elif command -v apt-get >/dev/null 2>&1; then
          apt-get remove -y #{options.name}
        else
          echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
          exit 2
        fi
        """
        code_skipped: 3
        if: ->
          installed.indexOf(options.name) isnt -1 
      , (err, {status}) ->
        throw Error "Invalid Service Name: #{options.name}" if err
        # Update list of installed packages
        installed.splice installed.indexOf(options.name), 1
        # Log information
        @log if status
        then message: "Service removed", level: 'WARN', module: 'nikita/lib/service/remove'
        else message: "Service already removed", level: 'INFO', module: 'nikita/lib/service/remove'
      @call
        if: options.cache
        handler: ->
          @log message: "Caching installed on \"nikita:execute:installed\"", level: 'INFO', module: 'nikita/lib/service/remove'
          @store['nikita:execute:installed'] = installed

## Dependencies

    string = require '../misc/string'
