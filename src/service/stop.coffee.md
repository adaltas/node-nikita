
# `mecano.service.stop(options, [callback])`

Start a service.

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
require('mecano').service.stop([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.stop", level: 'DEBUG', module: 'mecano/lib/service/stop'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      options.log message: "Stop service #{options.name}", level: 'INFO', module: 'mecano/lib/service/stop'
      options.os ?= {}
      @system.discover cache: options.cache, shy: true, (err, status, os) -> 
        options.os.type ?= os.type
        options.os.release ?= os.release
      @service.discover cache: options.cache, shy: true, (err, status, loader) -> 
        options.loader ?= loader
      @call
        if: -> options.os.type in ['redhat','centos','ubuntu']
        if_exec: "ls /lib/systemd/system/*.service /etc/systemd/system/*.service /etc/rc.d/ /etc/init.d/* 2>/dev/null | grep #{options.name}"
      , ->
        @service.status
          name: options.name
          code_started: options.code_started
          code_stopped: options.code_stopped
          shy: true
        @system.execute
          cmd: switch options.loader
            when 'systemctl' then "systemctl stop #{options.name}"
            when 'service' then "service #{options.name} stop"
            else throw Error 'Init System not supported'
          if: -> @status -1
        , (err, stopped) ->
          throw err if err
          options.store["mecano.service.#{options.name}.status"] = 'stopped' if not err and options.cache
