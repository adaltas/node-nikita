
# `nikita.service.start(options, [callback])`

Start a service. Note, does not throw an error if service is not installed.

## Options

* `arch_chroot` (boolean|string)   
  Run this command inside a root directory with the arc-chroot command or any 
  provided string, require the "rootdir" option if activated.   
* `rootdir` (string)   
  Path to the mount point corresponding to the root directory, required if 
  the "arch_chroot" option is activated.   
* `name` (string)   
  Service name.   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Indicates if the service was started ("true") or if it was already running 
  ("false").   

## Example

```js
require('nikita').service.start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.start", level: 'DEBUG', module: 'nikita/lib/service/start'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      @system.execute
        cmd: """
        ls \
          /lib/systemd/system/*.service \
          /etc/systemd/system/*.service \
          /etc/rc.d/* \
          /etc/init.d/* \
          2>/dev/null \
        | grep -w "#{options.name}" || exit 3
        if command -v systemctl >/dev/null 2>&1; then
          systemctl status #{options.name} && exit 3
          systemctl start #{options.name}
        elif command -v service >/dev/null 2>&1; then
          service #{options.name} status && exit 3
          service #{options.name} start
        else
          echo "Unsupported Loader" >&2
          exit 2
        fi
        """
        code_skipped: 3
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
      , (err, started) ->
        options.log message: "Service already started", level: 'WARN', module: 'nikita/lib/service/start' if not err and not started
        options.log message: "Service is started", level: 'INFO', module: 'nikita/lib/service/start' if not err and started
