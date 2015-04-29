
# `service_start(options, callback)` 

Start a service.

## Options

*   `name` (string)   
    Service name.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
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
}, function(err, modified){ /* do sth */ });
```

## Source Code

    module.exports = (options, callback) ->
      wrap @, arguments, (options, callback) ->
        return callback new Error "Missing required option 'name'" unless options.name
        @child()
        .execute
          ssh: options.ssh
          cmd: "service #{options.name} status"
          code_skipped: [3, 1] # ntpd return 1 if pidfile exists without a matching process
          log: options.log
          stdout: options.stdout
          stderr: options.stderr
          shy: true
        , (err, started) ->
          return callback err if err
          options.db["mecano.service.start.#{options.name}.status"] = if started
          then 'started'
          else 'stopped'
        .execute
          ssh: options.ssh
          cmd: "service #{options.name} start"
          log: options.log
          stdout: options.stdout
          stderr: options.stderr
          not_if: (options) ->
            options.db["mecano.service.start.#{options.name}.status"] is 'started'
        , (err, executed) ->
          return callback err if err
          options.db["mecano.service.start.#{options.name}.status"] is 'started'
        .then callback

## Dependencies

    execute = require './execute'
    wrap = require './misc/wrap'



