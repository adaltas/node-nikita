
# `nikita.docker.logout(options, [callback])`

Log out from a Docker registry, if no server is
specified  is the default.

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.
* `registry` (string)   
  Address of the registry server, default to "https://index.docker.io/v1/".
* `machine` (string)   
  Name of the docker-machine, required if using docker-machine.
* `code` (int|array)   
  Expected code(s) returned by the command, int or array of int, default to 0.
* `code_skipped`   
  Expected code(s) returned by the command if it has no effect, executed will
  not be incremented, int or array of int.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True if logout.

## Example

```javascript
nikita.docker.pause({
  container: 'toto'
}, function(err, status){
  console.log( err ? err.message : 'Logout: ' + status);
})
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering Docker logout", level: 'DEBUG', module: 'nikita/lib/docker/logout'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      return callback Error 'Missing container parameter' unless options.container?
      # rm is false by default only if options.service is true
      cmd = 'logout'
      cmd += " \"#{options.registry}\"" if options.registry?
      @system.execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
    util = require 'util'
