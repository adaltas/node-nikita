
# `nikita.lxd.stop`

Start a running Linux Container.

## Options

* `container` (required, string)
  The name of the container

## Example

```
require('nikita')
.lxd.stop({
  container: "myubuntu"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was stopped')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering stop", level: 'DEBUG', module: '@nikitajs/lxd/lib/stop'
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      @system.execute
        cmd: """
        lxc list -c ns --format csv | grep '#{options.container},STOPPED' && exit 42
        lxc stop #{options.container}
        """
        code_skipped: 42

## Dependencies

    validate_container_name = require './misc/validate_container_name'
