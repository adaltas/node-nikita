
# `nikita.lxd.network.attach`

Attach an existing network to a container.

## Options

* `network` (required, string)   
  The network network.
* `container` (required, string)   
  The container name.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if the network was attached.

## Example

```js
require('nikita')
.lxd.network.attach({
  network: 'network0',
  container: 'container1'
}, function(err, {status}){
  console.log( err ? err.message : 'Network attached: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd network attach", level: "DEBUG", module: "@nikitajs/lxd/lib/network/attach"
      #Check args
      throw Error "Invalid Option: network is required" unless options.network
      throw Error "Invalid Option: container is required" unless options.container
      #Build command
      cmd_attach = [
        'lxc'
        'network'
        'attach'
        options.network
        options.container
      ].join ' '
      #Execute
      @system.execute
        cmd: """
        lxc config device list #{options.container} | grep #{options.network} && exit 42
        #{cmd_attach}
        """
        code_skipped: 42
