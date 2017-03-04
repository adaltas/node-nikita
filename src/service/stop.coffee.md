
# `nikita.service.stop(options, [callback])`

Start a service. Note, does not throw an error if service is not installed.

## Options

*   `cache` (boolean)   
    Cache system and service information.   
*   `name` (string)   
    Service name.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `code_started` (int|string|array)   
    Expected code(s) returned by service status for STARTED, int or array of
    int, default to 0.   
*   `code_stopped` (int|string|array)   
    Expected code(s) returned by service status for STOPPED, int or array of 
    int, default to 3   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Indicates if the startup behavior has changed.   

## Example

```js
require('nikita').service.stop([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.stop", level: 'DEBUG', module: 'nikita/lib/service/stop'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      options.log message: "Stop service #{options.name}", level: 'INFO', module: 'nikita/lib/service/stop'
      @system.execute
        cmd: """
        ls \
          /lib/systemd/system/*.service \
          /etc/systemd/system/*.service \
          /etc/rc.d/* \
          /etc/init.d/* \
          2>/dev/null \
        | grep -w "#{options.name}" || exit 3
        if which systemctl >/dev/null; then
          systemctl status #{options.name} || exit 3
          systemctl stop #{options.name}
        elif which service >/dev/null; then
          service #{options.name} status || exit 3
          service #{options.name} stop
        else
          echo "Unsupported Loader"
          exit 2
        fi
        """
        code_skipped: 3
      , (err, status) ->
        options.log message: "Service already stopped", level: 'WARN', module: 'nikita/lib/service/stop' if not err and not status
        options.log message: "Service is stopped", level: 'INFO', module: 'nikita/lib/service/stop' if not err and status
