
# `nikita.lxc.storage.volume.list`

Show the list of volumes in a storage pool.

## Output parameters

* `$status`
  True if the list was issued properly.
* `list`
  List of volumes in the pool.

## Example

```js
const {list} = await @lxc.storage.volume.list({
  pool = 'default'
})
console.info(`The pool contains the following volumes: ${list}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'pool':
            type: 'string'
            description: '''
            Name of the storage pool containing the volumes you want to list.
            '''
          'type':
            enum: ["custom"]
            default: "custom"
            description: '''
            Type of storage volumes to list.
            ''' 
        required: ['pool']

## Handler

    handler = ({config}) ->
      {$status, data} = await @lxc.query
        path: "/1.0/storage-pools/#{config.pool}/volumes/#{config.type}"
        code: [0, 42]
      $status: $status
      list: (i.split('/').pop() for i in data)

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
