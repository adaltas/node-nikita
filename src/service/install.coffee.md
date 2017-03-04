
# `nikita.service.install(options, [callback])`

Install a service. Yum and apt-get are supported.

## Options

*   `cacheonly` (boolean)   
    Run the yum command entirely from system cache, don't update cache.   
*   `code_skipped` (integer|array)   
     Error code to skip when using nikita.service.   
*   `name` (string)   
    Package name, optional.   
    
## Example

```js
require('nikita').service.install({
  ssh: ssh,
  name: 'ntp'
}, function(err, status){
  console.log(err || "Package installed: " + status ? 'yes' : 'no');
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.install", level: 'DEBUG', module: 'nikita/lib/service/install'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Action
      options.log message: "Install service #{options.name}", level: 'INFO', module: 'nikita/lib/service/install'
      installed = updates = null
      if options.cache
        installed = options.store['nikita:execute:installed']
        updates = options.store['nikita:execute:updates']
      options.manager ?= options.store['nikita:service:manager']
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Start real work
      cacheonly = if options.cacheonly then '-C' else ''
      # List installed packages
      @system.execute
        cmd: """
        if which yum >/dev/null; then
          rpm -qa --qf "%{NAME}\n"
        elif which apt-get >/dev/null; then
          dpkg -l | grep \'^ii\' | awk \'{print $2}\'
        fi
        """
        code_skipped: 1
        stdout_log: false
        shy: true
        unless: installed?
        # if: -> not options.cache or not installed
      , (err, status, stdout) ->
        throw err if err
        return unless status
        options.log message: "Installed packages retrieved", level: 'INFO', module: 'nikita/service/install'
        installed = for pkg in string.lines(stdout) then pkg
      # List packages waiting for update
      @system.execute
        cmd: """
        if which yum >/dev/null; then
          yum #{cacheonly} list updates | egrep updates$ | sed 's/\\([^\\.]*\\).*/\\1/'
        elif which apt-get >/dev/null; then
          apt-get -u upgrade --assume-no | grep '^\\s' | sed 's/\\s/\\n/g'
        fi
        """
        code_skipped: 1
        stdout_log: false
        shy: true
        unless: updates?
        if: -> installed.indexOf(options.name) is -1
      , (err, status, stdout) ->
        throw err if err
        return updates = [] unless status
        options.log message: "Available updates retrieved", level: 'INFO', module: 'nikita/service/install'
        updates = string.lines stdout.trim()
      @system.execute
        cmd: """
        if which yum >/dev/null; then
          yum install -y #{cacheonly} #{options.name}
        elif which apt-get >/dev/null; then
          apt-get install -y #{options.name}
        fi
        """
        code_skipped: options.code_skipped
        if: ->
          installed.indexOf(options.name) is -1 or updates.indexOf(options.name) isnt -1
      , (err, status) ->
        throw err if err
        options.log if status
        then message: "Package \"#{options.name}\" is installed", level: 'WARN', module: 'nikita/service/install'
        else message: "Package \"#{options.name}\" is already installed", level: 'WARN', module: 'nikita/service/install'
        # Enrich installed array with package name unless already there
        installedIndex = installed.indexOf options.name
        installed.push options.name if installedIndex is -1
        # Remove package name from updates if listed
        if updates
          updatesIndex = updates.indexOf options.name
          updates.splice updatesIndex, 1 unless updatesIndex is -1
      @call
        if: options.cache
        handler: ->
          options.log message: "Caching installed on \"nikita:execute:installed\"", level: 'INFO', module: 'nikita/service/install'
          options.store['nikita:execute:installed'] = installed
          options.log message: "Caching updates on \"nikita:execute:updates\"", level: 'INFO', module: 'nikita/service/install'
          options.store['nikita:execute:updates'] = updates

## Dependencies

    string = require '../misc/string'
