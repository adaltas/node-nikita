
# `service_start(options, callback)`

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
require('mecano').service_start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service_start", level: 'DEBUG', module: 'mecano/lib/service/start'
      throw Error "Missing required option 'name'" unless options.name
      @service_status
        name: options.name
        code_started: options.code_started
        code_stopped: options.code_stopped
        shy: true
      @execute
        cmd: "service #{options.name} start"
        unless: [
          -> @status -1
          -> options.cache and options.store["mecano.service.#{options.name}.status"] is 'started'
        ]
      , (err, started) ->
        throw err if err
        options.store["mecano.service.#{options.name}.status"] = 'started' if not err and options.cache
