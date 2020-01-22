
# `nikita.lxd.start`

Start containers.

## Options

* `container` (string, required)
  The name of the container.

## Callback Parameters

* `err`
  Error object if any.
* `info.status`
  Was the container started or already running.

## Example

```
require('nikita')
.lxd.start({
  container: "my_container"
}, function(err, {status}) {
  console.log( err ? err.message :
    status ? 'Container now running' : 'Container already running' )
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering lxd.start", level: 'DEBUG', module: '@nikitajs/lxd/lib/start'
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      cmd_init = [
        'lxc', 'start', options.container
      ].join ' '
      # Execution
      @system.execute
        container: options.container
        cmd: """
        lxc list -c ns --format csv | grep '#{options.container},RUNNING' && exit 42
        #{cmd_init}
        """
        code_skipped: 42

## Dependencies

    validate_container_name = require './misc/validate_container_name'
