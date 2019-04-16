
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
      @log message: "Entering lxd.init", level: 'DEBUG', module: '@nikitajs/lxd/lib/init'
      throw Error "Invalid Option: name is required" unless options.container
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
