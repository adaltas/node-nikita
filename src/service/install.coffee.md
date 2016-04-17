
# `service_install(options, callback)`

Install a service. For now, only Yum over SSH.

## Options

*   `cacheonly` (boolean)   
    Run the yum command entirely from system cache, don't update cache.   
*   `name` (string)   
    Package name, optional.   
    
## Example

```js
require('mecano').service_install([{
  ssh: ssh,
  name: 'ntp'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service", level: 'DEBUG', module: 'mecano/lib/service/install'
      installed = updates = null
      modified = false
      if options.cache
        installed = options.store['mecano:execute:installed']
        updates = options.store['mecano:execute:updates']
      # Start real work
      # Note for legaciy
      # c = if options.cache then '-C' else ''
      # @execute: cmd: "yum #{c} list installed"
      # for pkg in string.lines stdout
      #   start = true if pkg.trim() is 'Installed Packages'
      #   continue unless start
      #   installed.push pkg[1] if pkg = /^([^\. ]+?)\./.exec pkg
      cacheonly = if options.cacheonly then '-C' else ''
      @execute
        cmd: 'rpm -qa --qf "%{NAME}\n"'
        code_skipped: 1
        stdout_log: false
        shy: true
        if: -> not options.cache or not installed
      , (err, executed, stdout) ->
        throw err if err
        return unless executed
        options.log message: "Installed packages retrieved", level: 'INFO', module: 'mecano/service/install'
        installed = for pkg in string.lines(stdout) then pkg
      @execute
        cmd: "yum #{cacheonly} list updates"
        code_skipped: 1
        unless: updates
        stdout_log: false
        shy: true
        if: -> installed.indexOf(options.name) is -1 
      , (err, executed, stdout) ->
        throw err if err
        return unless executed
        options.log message: "Available updates retrieved", level: 'INFO', module: 'mecano/service/install'
        start = false
        updates = for pkg in string.lines(stdout)
          start = true if pkg.trim() is 'Updated Packages'
          continue unless start
          continue unless pkg = /^([^\. ]+?)\./.exec pkg
          pkg[1]
      @execute
        cmd: "yum install -y #{cacheonly} #{options.name}"
        if: [
          -> installed.indexOf(options.name) is -1
          -> updates.indexOf(options.name) is -1
        ]
      , (err, succeed) ->
        throw err if err
        options.log if succeed
        then message: "Package \"#{options.name}\" is installed", level: 'WARN', module: 'mecano/service/install'
        else message: "Package \"#{options.name}\" is already installed", level: 'WARN', module: 'mecano/service/install'
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
          options.log message: "Caching installed on \"mecano:execute:installed\"", level: 'INFO', module: 'mecano/service/install'
          options.store['mecano:execute:installed'] = installed
          options.log message: "Caching updates on \"mecano:execute:updates\"", level: 'INFO', module: 'mecano/service/install'
          options.store['mecano:execute:updates'] = updates

## Dependencies

    string = require '../misc/string'
