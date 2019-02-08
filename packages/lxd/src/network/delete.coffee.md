
# `nikita.lxd.network.delete`

Delete an existing lxd network.

## Options

* `name` (required, string)
  The network name

## Callback parameters

* `err`
  Error object if any
* `status`
  True if the network was deleted

## Example

```js
require('nikita')
.lxd.network.delete({
  name: 'network0'
}, function(err, {status}){
  console.log( err ? err.message : 'Network deleted: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd network delete", level: "DEBUG", module: "@nikitajs/lxd/lib/network/delete"
      #Check args
      throw Error "Argument 'name' is required to delete a network" unless options.name
      #Build command
      cmd_delete = [
        'lxc'
        'network'
        'delete'
         options.name
      ].join ' '
      #Execute
      @system.execute
        cmd: """
        lxc network list --format csv | grep #{options.name} || exit 42
        #{cmd_delete}
        """
        code_skipped: 42
