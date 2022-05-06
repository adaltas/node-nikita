
# `nikita.lxc.storage.volume`

Create a new storage volume in the selected pool.

## Output parameters

* `$status`
  True if the volume was created.

## Example

```js
const {$status} = await @lxc.storage({
  pool = 'default',
  name = 'test',
})
console.info(`The pool creation was correctly made: ${$status}`)
```

## Schema definitions
          
    definitions =
      config:
        type: 'object'
        properties:
          'pool':
            type: 'string'
            description: '''
            Name of the storage pool to create the volume in.
            '''
          'name':
            type: 'string'
            description: '''
            Name of the storage volume to create.
            '''
          'type':
            enum: ["custom"]
            default: "custom"
            description: '''
            Type of the storage volume to create.
            '''
          'properties':
            type: 'object',
            patternProperties: '': type: ['string', 'boolean', 'number']
            description: '''
            Configuration to use to configure this storage volume. 
            '''
          'content':
            enum: ["filesystem", "block"]
            default: "filesystem"
            description: '''
            Type of content to create in the storage volume.
            Filesystem is for containers and block is for virtual machines.
            '''
          'description':
            type: 'string'
            description: '''
            Description of the storage volume.
            '''
        required: ['name', 'pool', 'type']

## Handler

    handler = ({config}) ->
      parameters = JSON.stringify {
        name: config.name,
        config: if config.properties? then config.properties else {},
        content_type: if config.content? then config.content else null,
        description: if config.description? then config.description else null,
      }
      {$status} = await @lxc.query
        path: "/1.0/storage-pools/#{config.pool}/volumes/#{config.type}"
        request: "POST"
        data: parameters
        format: 'string'
        code: [0, 42]
      $status: $status
      

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
