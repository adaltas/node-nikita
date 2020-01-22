
# `nikita.lxd.network.delete`

Delete an existing lxd network.

## Options

* `network` (required, string)   
  The network name.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if the network was deleted.

## Example

```js
require('nikita')
.lxd.network.delete({
  network: 'network0'
}, function(err, {status}){
  console.log( err ? err.message : 'Network deleted: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd.network.delete", level: "DEBUG", module: "@nikitajs/lxd/lib/network/delete"
      #Check args
      throw Error "Invalid Option: network is required" unless options.network
      #Execute
      @system.execute
        cmd: """
        lxc network list --format csv | grep #{options.network} || exit 42
        #{[
          'lxc'
          'network'
          'delete'
           options.network
        ].join ' '}
        """
        code_skipped: 42
