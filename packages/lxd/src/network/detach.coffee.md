
# `nikita.lxd.network.detach`

Detach a network from a container.

## Options

* `network` (required, string)   
  The network name.
* `container` (required, string)   
  The container name.

## Callback parameters

* `err`
  Error object if any
* `status`
  True if the network was detached

## Example

```js
require('nikita')
.lxd.network.detach({
  network: 'network0'
  container: 'container1'
}, function(err, {status}){
  console.info( err ? err.message : 'Network detached  : ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd.network.detach", level: "DEBUG", module: "@nikitajs/lxd/lib/network/detach"
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      throw Error "Invalid Option: network is required" unless options.network
      #Execute
      @system.execute
        cmd: """
        lxc config device list #{options.container} | grep #{options.network} || exit 42
        #{[
          'lxc'
          'network'
          'detach'
           options.network
           options.container
        ].join ' '}
        """
        code_skipped: 42

## Dependencies

    validate_container_name = require '../misc/validate_container_name'
