# `nikita.lxc.delete`

Delete a Linux Container using lxc

## Options

* `name`
  The name of the container
* `force` (optional default: false)
  If true, the container will be deleted even if running

## Callback Parameters
* `err`
  Error object if any
* `status`
  Was the container successfully created

## Example
```
require('nikita')
.lxc.delete({
  name: "myubuntu"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was deleted')
});

```

## Source Code

    module.exports =  ({options}, callback) ->
      @log message: "Entering delete", level: 'DEBUG', module: 'nikita/lxc/delete'
      # Building command
      cmd = ['lxc', options.name]
      cmd.push "--force" if options.force  
      # Execution
      @system.execute
        cmd: cmd.join ' '
      , callback
