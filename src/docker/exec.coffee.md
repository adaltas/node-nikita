
# `nikita.docker.exec(options, [callback])`

Run a command in a running container

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `container` (string)   
  Name/ID of the container, required.
* `code_skipped` (int | array)   
  The exit code(s) to skip.
* `machine` (string)   
  Name of the docker-machine, required using docker-machine.
* `service` (boolean)   
  if true, run container as a service, else run as a command, true by default.
* `uid` (name | uid)   
  Username or uid.
* `gid` (name | gid)   
  Groupname or gid.


## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True if command was executed in container.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.   
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.   

## Example

```javascript
nikita.docker({
  ssh: ssh,
  container: 'myContainer',
  cmd: '/bin/bash -c "echo toto"'
}, function(err, status, stdout, stderr){
  console.log( err ? err.message : 'Command executed: ' + status);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering Docker exec", level: 'DEBUG', module: 'nikita/lib/docker/exec'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters
      throw Error 'Missing container' unless options.container?
      throw Error 'Missing cmd' unless options.cmd?
      options.service ?= false
      # Construct exec command
      cmd = 'exec'
      if options.uid?
        cmd += " -u #{options.uid}"
        cmd += ":#{options.gid}" if options.gid?
      else if options.gid?
        options.log message: 'options.gid ignored unless options.uid is provided', level: 'WARN', module: 'nikita/lib/docker/exec'
      cmd += " #{options.container} #{options.cmd}"
      delete options.cmd
      @system.execute
        cmd: docker.wrap options, cmd
        code_skipped: options.code_skipped
      # Note: There is no way to pass additionnal arguments in sync mode without
      # a callback, or we would have ', docker.callback' as next line
      , ->
        try
          docker.callback.call null, arguments...
        catch e then arguments[0] = e
        callback arguments...

## Modules Dependencies

    docker = require '../misc/docker'
