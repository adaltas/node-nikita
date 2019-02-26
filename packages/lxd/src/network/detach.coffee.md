
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
  console.log( err ? err.message : 'Network detached  : ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd network detach", level: "DEBUG", module: "@nikitajs/lxd/lib/network/detach"
      #Check args
      throw Error "Invalid Option: network is required" unless options.network
      throw Error "Invalid Option: container is required" unless options.container
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
