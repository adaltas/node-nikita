
# `nikita.lxd.storage.delete`

Delete an existing lxd storage.

## Output

* `$status`
  True if the object was deleted

## Example

```js
const {$status} = await nikita.lxd.storage.delete({
  name: 'system'
})
console.info(`Storage was deleted: ${$status}`)
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
      command_delete = [
        'lxc'
        'storage'
        'delete'
         config.name
      ].join ' '
      #Execute
      await @execute
        command: """
        lxc storage list | grep #{config.name} || exit 42
        #{command_delete}
        """
        code_skipped: 42

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema
