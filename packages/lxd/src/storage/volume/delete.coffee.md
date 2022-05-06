
# `nikita.lxc.storage.volume.delete`

Delete a storage volume in the selected pool.

## Output parameters

* `$status`
  True if the volume was deleted.

## Example

```js
const {$status} = await @lxc.storage.volume.delete({
  pool = 'default',
  name = 'test',
})
console.info(`The volume was deleted: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'pool':
            type: 'string'
            description: 'Name of the storage pool containing the volume to delete.'
          'name':
            type: 'string'
            description: 'Name of the storage volume to delete.'
          'type':
            enum: ["custom"]
            default: "custom"
            description: '''
            Type of the storage volume to delete.
            '''
        required: ['pool', 'name', 'type']

## Handler

    handler = ({config}) ->
      {$status} = await @lxc.query
        path: "/1.0/storage-pools/#{config.pool}/volumes/#{config.type}/#{config.name}"
        request: "DELETE"
        format: 'string'
        code: [0, 42]
      $status: $status
      
## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
