
# `nikita.lxd.network.detach`

Detach a network from a container.

## Options

* `name` (required, string)
  The network name
* `container` (required, string)
  The container name

## Callback parameters

* `err`
  Error object if any
* `status`
  True if the network was detached

## Example

```js
require('nikita')
.lxd.network.detach({
  name: 'network0'
  container: 'container1'
}, function(err, {status}){
  console.log( err ? err.message : 'Network detached  : ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd network detach", level: "DEBUG", module: "@nikitajs/lxd/lib/network/detach"
      #Check args
      throw Error "Argument 'name' is required to detach a container from a network" unless options.name
      throw Error "Argument 'container' is required to detach a container from a network" unless options.name
      #Build command
      cmd_detach = [
        'lxc'
        'network'
        'detach'
         options.name
         options.container
      ].join ' '
      #Execute
      @system.execute
        cmd: """
        lxc config device list #{options.container} | grep #{options.name} || exit 42
        #{cmd_detach}
        """
        code_skipped: 42
