
# `nikita.service.restart(options, [callback])`

Start a service.

## Options

* `name` (string)   
  Service name.   
* `ssh` (object|ssh2)   
  Run the action on a remote server using SSH, an ssh2 instance or an
  configuration object used to initialize the SSH connection.   
* `stdout` (stream.Writable)   
  Writable EventEmitter in which the standard output of executed commands will
  be piped.   
* `stderr` (stream.Writable)   
  Writable EventEmitter in which the standard error output of executed command
  will be piped.   

## Callback parameters

* `err`   
  Error object if any.   
* `modified`   
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
      @log message: "Entering service.restart", level: 'DEBUG', module: 'nikita/lib/service/restart'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      @log message: "Restart service #{options.name}", level: 'INFO', module: 'nikita/lib/service/restart'
      @service.discover (err, {loader}) -> 
        options.loader ?= loader
      @call ->
        cmd = switch options.loader
          when 'systemctl' then "systemctl restart #{options.name}"
          when 'service' then "service #{options.name} restart"
          else throw Error 'Init System not supported'
        @system.execute
          cmd: cmd
        , (err, {status}) ->
          throw err if err
          @store["nikita.service.#{options.name}.status"] = 'started' if status
