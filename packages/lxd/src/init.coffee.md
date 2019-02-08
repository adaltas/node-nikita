
# `nikita.lxd.init`

Initialize a Linux Container with given image name, container name and options.

## Options

* `image` (required, string)
  The image the container will use, name:[version] e.g: ubuntu:16.04
* `name` (required, string)
  The name of the container
* `network` (optional, string, )
  Network name to add to the container (see lxd.network)
* `storage` (optional, string, [default_storage])
  Storage name where to store the container
* `profile` (optional, string, default)
  Profile to set this container up
* `ephemeral` (optional, boolean, false)
  If true, the container will be deleted when stopped

## Callback Parameters

* `err`
  Error object if any
* `info.status`
  Was the container successfully created

## Example

```
require('nikita')
.lxd.init({
  image: "ubuntu:18.04",
  name: "my_container"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was created')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering lxd.init", level: 'DEBUG', module: '@nikitajs/lxd/lib/init'
      throw Error "Invalid Option: name is required" unless options.name
      cmd_init = [
        'lxc', 'init', options.image, options.name
        "--network #{options.network}" if options.network
        "--storage #{options.storage}" if options.storage
        "--ephemeral" if options.ephemeral
      ].join ' '
      # Execution
      @system.execute
        name: options.name
        cmd: """
        lxc info #{options.name} >/dev/null && exit 42
        #{cmd_init}
        """
        code_skipped: 42
