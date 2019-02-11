
# `nikita.lxd.running`

Start containers.

## Options

* `name` (string, required)
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
  name: "my_container"
}, function(err, {status}) {
  console.log( err ? err.message : 
    status ? 'Container is running' : 'Container is not running' )
});
```

## Source Code

    module.exports = shy: true, handler: ({options}) ->
      @log message: "Entering lxd.init", level: 'DEBUG', module: '@nikitajs/lxd/lib/init'
      throw Error "Invalid Option: name is required" unless options.name
      @system.execute
        name: options.name
        cmd: """
        lxc list -c ns --format csv | grep '#{options.name},RUNNING' || exit 42 
        """
        code_skipped: 42
