
# `nikita.lxd.delete`

Delete a Linux Container using lxd.

## Options

* `container` (required, string)
  The name of the container
* `force` (optional default: false)
  If true, the container will be deleted even if running

## Example

```
require('nikita')
.lxd.delete({
  container: "myubuntu"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was deleted')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering delete", level: 'DEBUG', module: '@nikitajs/lxd/lib/delete'
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      # Execution
      @system.execute
        cmd: """
        lxc info #{options.container} > /dev/null || exit 42
        #{[
          'lxc',
          'delete',
          options.container
          "--force" if options.force
        ].join ' '}
        """
        code_skipped: 42

## Dependencies

    validate_container_name = require './misc/validate_container_name'
