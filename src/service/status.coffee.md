
# `service_start(options, callback)`

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
require('mecano').service_start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service_status", level: 'DEBUG', module: 'mecano/lib/service/status'
      throw Error "Missing required option 'name'" unless options.name
      options.code_started ?= 0
      options.code_stopped ?= 3
      options.log message: "Get status for #{options.name}", level: 'DEBUG', module: 'mecano/lib/service/status'
      @execute
        cmd: """
        if [ ! -f /etc/init.d/#{options.name} ]; then exit 1; fi;
        service #{options.name} status || exit 3
        """
        code: options.code_started
        code_skipped: options.code_stopped
      , (err, started) ->
        throw Error "Invalid Service Name: #{options.name}" if err
        status = if started then 'started' else 'stopped'
        options.log message: "Status for #{options.name} is #{status}", level: 'INFO', module: 'mecano/lib/service/status'
        # throw err if err
        options.store["mecano.service.#{options.name}.status"] = "#{status}" if options.cache
