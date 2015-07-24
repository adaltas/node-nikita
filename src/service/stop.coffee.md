
# `service_stop(options, callback)`

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
require('mecano').service_stop([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options, callback) ->
      return callback new Error "Missing required option 'name'" unless options.name
      @
      .execute
        cmd: "service #{options.name} status"
        code_skipped: [3, 1] # ntpd return 1 if pidfile exists without a matching process
        shy: true
      , (err, started) ->
        return callback err if err
        options.db["mecano.service.#{options.name}.status"] = if started
        then 'started'
        else 'stopped'
      .execute
        cmd: "service #{options.name} stop"
        not_if: ->
          options.db["mecano.service.#{options.name}.status"] is 'stopped'
      .then callback

## Dependencies

    execute = require '../execute'
