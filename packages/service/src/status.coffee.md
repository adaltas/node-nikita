
# `nikita.service.status`

Status of a service. Note, does not throw an error if service is not installed.

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
  Indicates if the startup behavior has changed.   

## Example

```js
require('nikita')
.service.start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Notes

Historically, we had the following two options:

* `code_started` (int|string|array)   
Expected code(s) returned by the command for STARTED status, int or array of
int, default to 0.   
* `code_stopped` (int|string|array)   
Expected code(s) returned by the command for STOPPED status, int or array of 
int, default to 3   

We might think about re-integrating them.

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering service.status", level: 'DEBUG', module: 'nikita/lib/service/status'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      @log message: "Status for service #{options.name}", level: 'INFO', module: 'nikita/lib/service/status'
      @call -> @system.execute
        cmd: """
          ls \
            /lib/systemd/system/*.service \
            /etc/systemd/system/*.service \
            /etc/rc.d/* \
            /etc/init.d/* \
            2>/dev/null \
          | grep -w "#{options.name}" || exit 3
          if command -v systemctl >/dev/null 2>&1; then
            systemctl status #{options.name} || exit 3
          elif command -v service >/dev/null 2>&1; then
            service #{options.name} status || exit 3
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
          """
        code: 0
        code_skipped: 3
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
      , (err, {status}) ->
        throw Error "Unsupported Loader" if err?.code is 2
        return if err
        @log message: "Status for #{options.name} is #{if status then 'started' else 'stoped'}", level: 'INFO', module: 'nikita/lib/service/status'
