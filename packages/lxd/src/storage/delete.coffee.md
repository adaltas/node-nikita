
# `nikita.lxd.storage.delete`

Delete an existing lxd storage.

## Options

* `name` (required, string)
  The storage name

## Callback parameters

* `err`
  Error object if any
* `status`
  True if the object was deleted

## Example

```js
require('nikita')
.lxd.storage.delete({
  name: 'system'
}, function(err, {status}){
  console.info( err ? err.message : 'Storage deleted: ' + status);
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering lxd.storage.delete", level: "DEBUG", module: "@nikitajs/lxd/lib/storage/delete"
      #Check args
      throw Error "Argument 'name' is required to delete a storage" unless options.name
      #Build command
      cmd_delete = [
        'lxc'
        'storage'
        'delete'
         options.name
      ].join ' '
      #Execute
      @system.execute
        cmd: """
        lxc storage list | grep #{options.name} || exit 42
        #{cmd_delete}
        """
        code_skipped: 42
