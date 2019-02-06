
# `nikita.lxd.file.exists`

Push files into containers.

## Options

* `name` (string, required)   
  The name of the container.
* `target` (string, required)   
  File destination in the form of "<path>".
  overwrite the `target` option.

## Example

```
require('nikita')
.lxd.file.push({
  name: "myubuntu"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was deleted')
});

```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target

## Source Code

    module.exports =  shy: true, handler: ({options}) ->
      @log message: "Entering lxd.file.exists", level: 'DEBUG', module: '@nikitajs/lxd/lib/exists'
      throw Error "Invalid Option: name is required" unless options.name
      throw Error "Invalid Option: target is required" unless options.target
      @system.execute
        cmd: """
        lxc exec #{options.name} -- stat #{options.target}
        """
        code_skipped: 1
