
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
      options.log message: "Entering service_install", level: 'DEBUG', module: 'mecano/lib/service/install'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Action
      options.log message: "Install service #{options.name}", level: 'INFO', module: 'mecano/lib/service/install'
      installed = updates = null
      if options.cache
        installed = options.store['mecano:execute:installed']
        updates = options.store['mecano:execute:updates']
      options.manager ?= options.store['mecano:service:manager']
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
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
        cmd: """
        if which yum >/dev/null; then exit 1; fi
        if which apt-get >/dev/null; then exit 2; fi
        exit 3
        """
        code: [1, 2]
        unless: options.manager
        shy: true
      , (err, status, stdout, stderr, signal) ->
        throw Error "Undetected Package Manager" if err?.code is 3
        throw err if err
        return unless status
        options.manager = switch signal
          when 1 then 'yum'
          when 2 then 'apt'
        options.store['mecano:service:manager'] = options.manager if options.cache
      @execute
        cmd: -> switch options.manager
          when 'yum' then 'rpm -qa --qf "%{NAME}\n"'
          when 'apt' then 'dpkg -l | grep \'^ii\' | awk \'{print $2}\''
          else throw Error "Invalid Manager: #{options.manager}"
        code_skipped: 1
        stdout_log: false
        shy: true
        unless: installed?
        # if: -> not options.cache or not installed
      , (err, executed, stdout) ->
        throw err if err
        return unless executed
        options.log message: "Installed packages retrieved", level: 'INFO', module: 'mecano/service/install'
        installed = for pkg in string.lines(stdout) then pkg
      @execute
        cmd: -> switch options.manager
          when 'yum' then "yum #{cacheonly} list updates"
          when 'apt', 'apt-get' then "apt-get -u upgrade --assume-no | grep '^\\s' | sed 's/\\s/\\n/g'"
          else throw Error "Invalid Manager: #{options.manager}"
        code_skipped: 1
        stdout_log: false
        shy: true
        unless: updates?
        if: -> installed.indexOf(options.name) is -1
      , (err, executed, stdout) ->
        throw err if err
        return updates = [] unless executed
        options.log message: "Available updates retrieved", level: 'INFO', module: 'mecano/service/install'
        start = false
        # if options.manager is 'yum' then updates = for pkg in string.lines(stdout)
        #   start = true if pkg.trim() is 'Updated Packages'
        #   continue unless start
        #   continue unless pkg = /^([^\. ]+?)\./.exec pkg
        #   pkg[1]
        updates = switch options.manager
          when 'yum' then for pkg in string.lines stdout
            start = true if pkg.trim() is 'Updated Packages'
            continue unless start
            continue unless pkg = /^([^\. ]+?)\./.exec pkg
            pkg[1]
          when 'apt' then string.lines stdout.trim()
      @execute
        cmd: -> switch options.manager
          when 'yum' then "yum install -y #{cacheonly} #{options.name}"
          when 'apt' then "apt-get install -y #{options.name}"
          else throw Error "Invalid Manager: #{options.manager}"
        if: ->
          installed.indexOf(options.name) is -1 or updates.indexOf(options.name) isnt -1
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
