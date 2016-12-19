
# `mecano.service.start(options, [callback])`

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
require('mecano').service.start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.restart", level: 'DEBUG', module: 'mecano/lib/service/restart'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      options.log message: "Restart service #{options.name}", level: 'INFO', module: 'mecano/lib/service/restart'
      @call discover.loader
      @call ->
        options.loader ?= options.store['mecano:service:loader']
        cmd = switch options.loader
          when 'systemctl' then "systemctl restart #{options.name}"
          when 'service' then "service #{options.name} restart"
          else throw Error 'Init System not supported'
        @execute
          cmd: cmd
        , (err, restarted) ->
          throw err if err
          options.store["mecano.service.#{options.name}.status"] = 'started' if restarted

## Dependencies
    
    discover = require '../misc/discover'
