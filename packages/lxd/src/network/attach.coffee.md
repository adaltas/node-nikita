
# `nikita.lxd.network.attach`

Attach an existing network to a container.

## Options

* `name` (required, string)
  The network name
* `container` (required, string)
  The container name

## Callback parameters

* `err`
  Error object if any
* `status`
  True if the network was attached

## Example

```js
require('nikita')
.lxd.network.attach({
  name: 'network0',
  container: 'container1'
}, function(err, {status}){
  console.log( err ? err.message : 'Network attached: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd network attach", level: "DEBUG", module: "@nikitajs/lxd/lib/network/attach"
      #Check args
      throw Error "Argument 'name' is required to attach a network" unless options.name
      throw Error "Argument 'container' is required to attach a network" unless options.container
      #Build command
      cmd_attach = [
        'lxc'
        'network'
        'attach'
        options.name
        options.container
      ].join ' '
      #Execute
      @system.execute
        cmd: """
        lxc config device list #{options.container} | grep #{options.name} && exit 42
        #{cmd_attach}
        """
        code_skipped: 42
