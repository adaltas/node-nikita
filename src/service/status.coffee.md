
# `mecano.service.status(options, [callback])`

Status of a service.

## Options

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
require('mecano').service.start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.status", level: 'DEBUG', module: 'mecano/lib/service/status'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      options.log message: "Status for service #{options.name}", level: 'INFO', module: 'mecano/lib/service/status'
      options.log message: "Option code_stopped is #{options.code_stopped}", level: 'DEBUG', module: 'mecano/lib/service/status' unless options.code_stopped is 3
      @call discover.loader, -> options.loader ?= options.store['mecano:service:loader']
      @call -> @system.execute
        if: -> options.store['mecano:system:type'] in ['redhat','centos']
        cmd: """
          ls \
            /lib/systemd/system/*.service \
            /etc/systemd/system/*.service \
            /etc/rc.d/* \
          | grep -w "#{options.name}" || exit 1
          case "#{options.loader}" in
            systemctl)
              systemctl status #{options.name} || exit 3
              ;;
            service)
              service #{options.name} status || exit 3
              ;;
            *)
              exit 2 # Unsupported Loader
              ;;
          esac
          """
        code: 0
        code_skipped: 3
      , (err, started) ->
        throw Error "Invalid Service Name: #{options.name}" if err
        status = if started then 'started' else 'stopped'
        options.log message: "Status for #{options.name} is #{status}", level: 'INFO', module: 'mecano/lib/service/status'
        # throw err if err
        options.store["mecano.service.#{options.name}.status"] = "#{status}" if options.cache

## Discover
  
    discover = require '../misc/discover'
