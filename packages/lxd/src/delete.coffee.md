
# `nikita.lxd.delete`

Delete a Linux Container using lxd.

## Options

* `name` (required, string)
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
      @log message: "Entering delete", level: 'DEBUG', module: '@nikitajs/lxd/lib/delete'
      #Check args
      throw Error "Invalid Option: name is required" unless options.name
      # Execution
      @system.execute
        cmd: """
        lxc info #{options.name} > /dev/null || exit 42
        #{[
          'lxc',
          'delete',
          options.name
          "--force" if options.force
        ].join ' '}
        """
        code_skipped: 42
