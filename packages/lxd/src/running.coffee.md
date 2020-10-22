
# `nikita.lxd.running`

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
.lxd.running({
  container: "my_container"
}, function(err, {status}) {
  console.info( err ? err.message :
    status ? 'Container is running' : 'Container is not running' )
});
```

## Source Code

    module.exports = shy: true, handler: ({options}) ->
      @log message: "Entering lxd.running", level: 'DEBUG', module: '@nikitajs/lxd/lib/running'
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      @system.execute
        container: options.container
        cmd: """
        lxc list -c ns --format csv | grep '#{options.container},RUNNING' || exit 42
        """
        code_skipped: 42

## Dependencies

    validate_container_name = require './misc/validate_container_name'
