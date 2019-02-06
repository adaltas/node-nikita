
# `nikita.lxd.delete`

Delete a Linux Container using lxd.

## Options

* `name`
  The name of the container
* `force` (optional default: false)
  If true, the container will be deleted even if running

## Example

```
require('nikita')
.lxd.delete({
  name: "myubuntu"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was deleted')
});

```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering delete", level: 'DEBUG', module: '@nikitajs/lxd/delete'
      # Building command
      cmd = ['lxd', options.name]
      cmd.push "--force" if options.force
      # Execution
      @system.execute
        cmd: cmd.join ' '
