
# `nikita.service.install(options, [callback])`

Install a service. Yum and apt-get are supported.

## Options

*   `arch_chroot` (boolean|string)   
    Run this command inside a root directory with the arc-chroot command or any 
    provided string, require the "rootdir" option if activated.   
*   `cache` (boolean)   
    Cache the list of installed and outpdated packages.   
*   `rootdir` (string)   
    Path to the mount point corresponding to the root directory, required if 
    the "arch_chroot" option is activated.   
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
      installed = outpdated = null
      if options.cache
        installed = options.store['nikita:execute:installed']
        outpdated = options.store['nikita:execute:outpdated']
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Start real work
      cacheonly = if options.cacheonly then '-C' else ''
      # List installed packages
      @system.execute
        unless: installed?
        cmd: """
        if which yum >/dev/null 2>&1; then
          rpm -qa --qf "%{NAME}\n"
        elif which pacman >/dev/null 2>&1; then
          pacman -Qqe
        elif which apt-get >/dev/null 2>&1; then
          dpkg -l | grep \'^ii\' | awk \'{print $2}\'
        else
          echo "Failed Package Installed" >&2
          exit 2
        fi
        """
        code_skipped: 1
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
        stdout_log: false
        shy: true
      , (err, status, stdout) ->
        throw Error "Failed Package Installed" if err?.code is 2
        throw err if err
        return unless status
        options.log message: "Installed packages retrieved", level: 'INFO', module: 'nikita/service/install'
        installed = for pkg in string.lines(stdout) then pkg
      # List packages waiting for update
      @system.execute
        unless: outpdated?
        if: -> installed.indexOf(options.name) is -1
        cmd: """
        if which yum >/dev/null 2>&1; then
          yum #{cacheonly} list updates | egrep updates$ | sed 's/\\([^\\.]*\\).*/\\1/'
        elif which pacman >/dev/null 2>&1; then
          pacman -Qu | sed 's/\\([^ ]*\\).*/\\1/'
        elif which apt-get >/dev/null 2>&1; then
          apt-get -u upgrade --assume-no | grep '^\\s' | sed 's/\\s/\\n/g'
        else
          echo "Failed Package Updates" >&2
          exit 2
        fi
        """
        code_skipped: 1
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
        stdout_log: false
        shy: true
      , (err, status, stdout) ->
        throw Error "Failed Package Updates" if err?.code is 2
        throw err if err
        return outpdated = [] unless status
        options.log message: "Outpdated package list retrieved", level: 'INFO', module: 'nikita/service/install'
        outpdated = string.lines stdout.trim()
      @system.execute
        if: -> installed.indexOf(options.name) is -1 or outpdated.indexOf(options.name) isnt -1
        cmd: """
        if which yum >/dev/null 2>&1; then
          yum install -y #{cacheonly} #{options.name}
        elif which yaourt >/dev/null 2>&1; then
          yaourt --noconfirm -S #{options.name}
        elif which pacman >/dev/null 2>&1; then
          pacman --noconfirm -S #{options.name}
        elif which apt-get >/dev/null 2>&1; then
          apt-get install -y #{options.name}
        else
          echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
          exit 2
        fi
        """
        code_skipped: options.code_skipped
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
      , (err, status) ->
        throw Error "Unsupported Package Manager: yum, yaourt, pacman, apt-get supported" if err?.code is 2
        throw err if err
        options.log if status
        then message: "Package \"#{options.name}\" is installed", level: 'WARN', module: 'nikita/service/install'
        else message: "Package \"#{options.name}\" is already installed", level: 'INFO', module: 'nikita/service/install'
        # Enrich installed array with package name unless already there
        installedIndex = installed.indexOf options.name
        installed.push options.name if installedIndex is -1
        # Remove package name from outpdated if listed
        if outpdated
          outpdatedIndex = outpdated.indexOf options.name
          outpdated.splice outpdatedIndex, 1 unless outpdatedIndex is -1
      @call
        if: options.cache
        handler: ->
          options.log message: "Caching installed on \"nikita:execute:installed\"", level: 'INFO', module: 'nikita/service/install'
          options.store['nikita:execute:installed'] = installed
          options.log message: "Caching outpdated list on \"nikita:execute:outpdated\"", level: 'INFO', module: 'nikita/service/install'
          options.store['nikita:execute:outpdated'] = outpdated

## Dependencies

    string = require '../misc/string'
