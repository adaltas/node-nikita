
# `nikita.lxd.file.exists`

Push files into containers.

## Options

* `container` (string, required)
  The name of the container.
* `target` (string, required)
  File destination in the form of "<path>".
  overwrite the `target` option.

## Example

```js
require('nikita')
.lxd.file.exists({
  container: "my_container"
}, function(err, {status}) {
  console.info( err ? err.message : 'The container was deleted')
});

```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target

## Source Code

    module.exports =  shy: true, handler: ({options}) ->
      @log message: "Entering lxd.file.exists", level: 'DEBUG', module: '@nikitajs/lxd/lib/file/exists'
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      throw Error "Invalid Option: target is required" unless options.target
      @system.execute
        cmd: """
        lxc exec #{options.container} -- stat #{options.target}
        """
        code_skipped: 1

## Dependencies

    validate_container_name = require '../misc/validate_container_name'
