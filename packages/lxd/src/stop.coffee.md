
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
      throw Error "Argument 'name' is required to stop a container" unless options.container
      @system.execute
        cmd: """
        lxc list -c ns --format csv | grep '#{options.container},STOPPED' && exit 42
        lxc stop #{options.container}
        """
        code_skipped: 42
