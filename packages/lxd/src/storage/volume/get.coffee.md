
# `nikita.lxc.storage.volume.get`

Get a storage volume in the selected pool.

## Output parameters

* `$status`
  True if the volume was obtained.
* `data`
  The data returned by the API call.

## Example

```js
const {data} = await @lxc.storage.volume.get({
  pool = 'default',
  name = 'test',
})
console.info(`The volume informations are: ${data}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'pool':
            type: 'string'
            description: 'Name of the storage pool containing the volume to get.'
          'name':
            type: 'string'
            description: 'Name of the storage volume to get.'
          'type':
            enum: ["custom"]
            default: "custom"
            description: '''
            Type of storage volume to get.
            '''
        required: ['pool', 'name', 'type']

## Handler

    handler = ({config}) ->
      {$status, data} = await @lxc.query
        path: "/1.0/storage-pools/#{config.pool}/volumes/#{config.type}/#{config.name}"
        code: [0, 42]
      $status: $status
      data: data
      
## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
