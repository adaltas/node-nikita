
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

    module.exports = (options, callback) ->
      return callback new Error "Missing required option 'name'" unless options.name
      options.code_started ?= 0
      options.code_stopped ?= 3
      @execute
        cmd: "service #{options.name} status"
        code: options.code_started
        code_skipped: options.code_stopped
      , (err, started) ->
        return callback err if err
        options.store["mecano.service.#{options.name}.status"] = if started
        then 'started'
        else 'stopped'
        callback null, started
