
# `mecano.service.start(options, [callback])`

Start a service.

## Options

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
require('mecano').service.start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.start", level: 'DEBUG', module: 'mecano/lib/service/start'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      options.log message: "Start service #{options.name}", level: 'INFO', module: 'mecano/lib/service/start'
      @call discover.system
      @call discover.loader, -> options.loader ?= options.store['mecano:service:loader']
      @call
        if: -> options.store['mecano:system:type'] in ['redhat','centos']
        if_exec: "ls /lib/systemd/system/*.service /etc/systemd/system/*.service /etc/rc.d/* | grep #{options.name}"
        handler: ->
          cmd = switch options.store['mecano:service:loader']
            when 'systemctl' then "systemctl start #{options.name}"
            when 'service' then "service #{options.name} start"
            else throw Error 'Init System not supported'
          @service.status
            name: options.name
            code_started: options.code_started
            code_stopped: options.code_stopped
            shy: true
          @system.execute
            cmd: cmd
            unless: [
              -> @status -1
              -> options.cache and options.store["mecano.service.#{options.name}.status"] is 'started'
            ]
          , (err, started) ->
            throw err if err
            options.store["mecano.service.#{options.name}.status"] = 'started' if not err and options.cache

## Discover
    
    discover = require '../misc/discover'
