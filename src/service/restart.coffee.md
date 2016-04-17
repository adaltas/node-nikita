
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
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service_restart", level: 'DEBUG', module: 'mecano/lib/service/restart'
      throw Error "Missing required option 'name'" unless options.name
      @execute
        cmd: "service #{options.name} restart"
      , (err, restarted) ->
        throw err if err
        options.store["mecano.service.#{options.name}.status"] = 'started' if restarted
