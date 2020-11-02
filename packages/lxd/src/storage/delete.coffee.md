
# `nikita.lxd.storage.delete`

Delete an existing lxd storage.

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

## Schema

    schema =
      type: 'object'
      properties:
        'name':
          type: 'string'
          description: """
          The storage name to delete.
          """
      required: ['name']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd.storage.delete", level: "DEBUG", module: "@nikitajs/lxd/lib/storage/delete"
      cmd_delete = [
        'lxc'
        'storage'
        'delete'
         config.name
      ].join ' '
      #Execute
      @execute
        cmd: """
        lxc storage list | grep #{config.name} || exit 42
        #{cmd_delete}
        """
        code_skipped: 42

## Export

    module.exports =
      handler: handler
      schema: schema
