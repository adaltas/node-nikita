
# `nikita.service.install`

Install a service. Yum, Yay, Yaourt, Pacman and apt-get are supported.

## Options

* `arch_chroot` (boolean|string)   
  Run this command inside a root directory with the arc-chroot command or any
  provided string, require the "rootdir" option if activated.
* `cache` (boolean)   
  Cache the list of installed and outpdated packages.
* `cacheonly` (boolean)   
  Run the yum command entirely from system cache, don't update cache.
* `code_skipped` (integer|array)   
   Error code to skip when using nikita.service.
* `installed`   
  Cache a list of installed services. If an object, the service will be
  installed if a key of the same name exists; if anything else (default), no
  caching will take place.
* `name` (string)   
  Package name, required unless provided as main argument.
* `outdated`   
  Cache a list of outdated services. If an object, the service will be updated
  if a key of the same name exists; If true, the option will be converted to
  an object with all the outdated service names as keys; if anything else
  (default), no caching will take place.
* `rootdir` (string)   
  Path to the mount point corresponding to the root directory, required if
  the "arch_chroot" option is activated.
* `pacman_flags` (array)
  Additionnal flags passed to the `pacman -S` command.
* `yaourt_flags` (array)
  Additionnal flags passed to the `yaourt -S` command.
* `yay_flags` (array)
  Additionnal flags passed to the `yay -S` command.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Indicates if the service was installed.   

## Example

```js
require('nikita')
.service.install({
  ssh: ssh,
  name: 'ntp'
}, function(err, {status}){
  console.log(err || "Package installed: " + status ? 'yes' : 'no');
});
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering service.install", level: 'DEBUG', module: 'nikita/lib/service/install'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      options.installed ?= @store['nikita:execute:installed'] if options.cache
      options.outpdated ?= @store['nikita:execute:outpdated'] if options.cache
      cacheonly = if options.cacheonly then '-C' else ''
      options.pacman_flags ?= []
      for flag, i in options.pacman_flags
        continue if /^-/.test flag
        options.pacman_flags[i] = "-#{flag}" if flag.length is 1
        options.pacman_flags[i] = "--#{flag}" if flag.length > 1
      options.yay_flags ?= []
      for flag, i in options.yay_flags
        continue if /^-/.test flag
        options.yay_flags[i] = "-#{flag}" if flag.length is 1
        options.yay_flags[i] = "--#{flag}" if flag.length > 1
      options.yaourt_flags ?= []
      for flag, i in options.yaourt_flags
        continue if /^-/.test flag
        options.yaourt_flags[i] = "-#{flag}" if flag.length is 1
        options.yaourt_flags[i] = "--#{flag}" if flag.length > 1
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Start real work
      @log message: "Install service #{options.name}", level: 'INFO', module: 'nikita/lib/service/install'
      # List installed packages
      @system.execute
        unless: options.installed?
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
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
        stdin_log: false
        stdout_log: false
        shy: true
      , (err, {status, stdout}) ->
        throw Error "Unsupported Package Manager" if err?.code is 2
        throw err if err
        return unless status
        @log message: "Installed packages retrieved", level: 'INFO', module: 'nikita/lib/service/install'
        options.installed = for pkg in string.lines(stdout) then pkg
      # List packages waiting for update
      @system.execute
        unless: options.outpdated?
        if: -> options.installed.indexOf(options.name) is -1
        cmd: """
        if command -v yum >/dev/null 2>&1; then
          yum #{cacheonly} list updates | egrep updates$ | sed 's/\\([^\\.]*\\).*/\\1/'
        elif command -v pacman >/dev/null 2>&1; then
          pacman -Qu | sed 's/\\([^ ]*\\).*/\\1/'
        elif command -v apt-get >/dev/null 2>&1; then
          apt-get -u upgrade --assume-no | grep '^\\s' | sed 's/\\s/\\n/g'
        else
          echo "Unsupported Package Manager" >&2
          exit 2
        fi
        """
        code_skipped: 1
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
        stdin_log: false
        stdout_log: false
        shy: true
      , (err, {status, stdout}) ->
        throw Error "Unsupported Package Manager" if err?.code is 2
        throw err if err
        return options.outpdated = [] unless status
        @log message: "Outpdated package list retrieved", level: 'INFO', module: 'nikita/lib/service/install'
        options.outpdated = string.lines stdout.trim()
      @system.execute
        if: -> options.installed.indexOf(options.name) is -1 or options.outpdated.indexOf(options.name) isnt -1
        cmd: """
        if command -v yum >/dev/null 2>&1; then
          yum install -y #{cacheonly} #{options.name}
        elif command -v yay >/dev/null 2>&1; then
          yay --noconfirm -S #{options.name} #{options.yay_flags.join ' '}
        elif command -v yaourt >/dev/null 2>&1; then
          yaourt --noconfirm -S #{options.name} #{options.yaourt_flags.join ' '}
        elif command -v pacman >/dev/null 2>&1; then
          pacman --noconfirm -S #{options.name} #{options.pacman_flags.join ' '}
        elif command -v apt-get >/dev/null 2>&1; then
          env DEBIAN_FRONTEND=noninteractive apt-get install -y #{options.name}
        else
          echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
          exit 2
        fi
        """
        code_skipped: options.code_skipped
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
      , (err, {status}) ->
        throw Error "Unsupported Package Manager: yum, yaourt, pacman, apt-get supported" if err?.code is 2
        throw err if err
        @log if status
        then message: "Package \"#{options.name}\" is installed", level: 'WARN', module: 'nikita/lib/service/install'
        else message: "Package \"#{options.name}\" is already installed", level: 'INFO', module: 'nikita/lib/service/install'
        # Enrich installed array with package name unless already there
        installedIndex = options.installed.indexOf options.name
        options.installed.push options.name if installedIndex is -1
        # Remove package name from outpdated if listed
        if options.outpdated
          outpdatedIndex = options.outpdated.indexOf options.name
          options.outpdated.splice outpdatedIndex, 1 unless outpdatedIndex is -1
      @call
        if: options.cache
      , ->
        @log message: "Caching installed on \"nikita:execute:installed\"", level: 'INFO', module: 'nikita/lib/service/install'
        @store['nikita:execute:installed'] = options.installed
        @log message: "Caching outpdated list on \"nikita:execute:outpdated\"", level: 'INFO', module: 'nikita/lib/service/install'
        @store['nikita:execute:outpdated'] = options.outpdated

## Dependencies

    string = require '../misc/string'
