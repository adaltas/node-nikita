
# `nikita.service.status(options, [callback])`

Status of a service. Note, does not throw an error if service is not installed.

## Options

*   `cache` (boolean)   
    Cache system and service information.   
*   `name` (string)   
    Service name.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `code_started` (int|string|array)   
    Expected code(s) returned by the command for STARTED status, int or array of
    int, default to 0.   
*   `code_stopped` (int|string|array)   
    Expected code(s) returned by the command for STOPPED status, int or array of 
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
require('nikita').service.start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.status", level: 'DEBUG', module: 'nikita/lib/service/status'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      options.log message: "Status for service #{options.name}", level: 'INFO', module: 'nikita/lib/service/status'
      options.log message: "Option code_stopped is #{options.code_stopped}", level: 'DEBUG', module: 'nikita/lib/service/status' unless options.code_stopped is 3
      @call -> @system.execute
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
          elif which service >/dev/null; then
            service #{options.name} status || exit 3
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
          """
        code: 0
        code_skipped: 3
      , (err, status) ->
        throw Error "Unsupported Loader" if err?.code is 2
        return if err
        options.log message: "Status for #{options.name} is #{if status then 'started' else 'stoped'}", level: 'INFO', module: 'nikita/lib/service/status'
