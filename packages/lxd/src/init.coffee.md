
# `nikita.lxd.init`

Initialize a Linux Container with given image name, container name and options.

## Options

* `image`
  The image the container will use, <name>:[version] e.g: ubuntu:16.04
* `name`
  The name of the container
* `network` (optional)
  Network name to add to the container (see lxd.network)
* `storage` (optional)
  Storage name where to store the container
* `profile` (optional)
  Profile to set this container up
* `ephemeral` (optional, default=false)
  If true, the container will be deleted when stopped

## Callback Parameters

* `err`
  Error object if any
* `status`
  Was the container successfully created

## Example

```
require('nikita')
.lxd.init({
  image: "ubuntu:18.04",
  name: "myubuntu"
}, function(err, {status}) {
  console.log( err ? err.message : 'The container was created')
});
```

## Source Code

    module.exports =  ({options}) ->
      @log message: "Entering init", level: 'DEBUG', module: '@nikitajs/lxd/init'
      # Building command
      cmd = ['lxd', options.image, options.name]
      #TODO: message/error if network is inexistant
      cmd.push "--network #{options.network}" if options.network
      #TODO: message/error if stotage does not exist
      cmd.push "--storage #{options.storage}" if options.storage
      cmd.push "--ephemeral" if options.ephemeral
      # Execution
      @system.execute
        cmd: cmd.join ' '
