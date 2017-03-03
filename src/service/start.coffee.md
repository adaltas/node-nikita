
# `nikita.service.start(options, [callback])`

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
      options.log message: "Start service #{options.name}", level: 'INFO', module: 'nikita/lib/service/start'
      options.os ?= {}
      @system.discover cache: options.cache, shy: true, (err, status, os) -> 
        options.os.type ?= os.type
        options.os.release ?= os.release
      @service.discover cache: options.cache, shy: true, (err, status, loader) -> 
        options.loader ?= loader
      @call
        if: -> options.os.type in ['redhat', 'centos', 'ubuntu']
        if_exec: "ls /lib/systemd/system/*.service /etc/systemd/system/*.service /etc/rc.d/* /etc/init.d/* 2>/dev/null | grep #{options.name}"
      , ->
        @service.status
          name: options.name
          code_started: options.code_started
          code_stopped: options.code_stopped
          shy: true
        @system.execute
          cmd: switch options.loader
            when 'systemctl' then "systemctl start #{options.name}"
            when 'service' then "service #{options.name} start"
            else throw Error 'Init System not supported'
          unless: [
            -> @status -1
            -> options.cache and options.store["nikita.service.#{options.name}.status"] is 'started'
          ]
        , (err, started) ->
          throw err if err
          options.store["nikita.service.#{options.name}.status"] = 'started' if not err and options.cache
