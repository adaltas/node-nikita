
# `nikita.lxd.stop`

Start a running Linux Container.

## Options

* `name` (required, string)
  The name of the container

## Example

```
require('nikita')
.lxd.stop({
  name: "myubuntu"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was stopped')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering stop", level: 'DEBUG', module: '@nikitajs/lxd/lib/stop'
      throw Error "Argument 'name' is required to stop a container" unless options.name
      # Building command
      cmd_stop = [
        'lxc'
        'stop'
        options.name
      ].join ' '
      # Execution
      @system.execute
        cmd: """
        lxc list -c ns --format csv | grep '#{options.name},STOPPED' && exit 42
        #{cmd_stop}
        """
        code_skipped: 42
