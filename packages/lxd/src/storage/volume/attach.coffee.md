
# `nikita.lxc.storage.volume.attach`

Attach a storage volume in the selected pool to an instance of LXD.

## Output parameters

* `$status`
  True if the volume was attached.

## Example

```js
const {$status} = await @lxc.storage.volume.attach({
  pool = 'default',
  name = 'test',
  container = 'c1',
  device = 'test'
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
            description: 'Name of the storage pool containing the volume to attach.'
          'name':
            type: 'string'
            description: 'Name of the storage volume to attach.'
          'device':
            type: 'string'
            description: 'Name of the device as listed in the instance.'
          'type':
            enum: ["custom"]
            default: "custom"
            description: '''
            Type of the storage volume to attach.
            '''
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
            description: '''
            Name of the container to attach the volume to.
            '''
          'path':
            type: 'string'
            description: '''
            Path to mount the volume in the instance.
            '''
        required: ['pool', 'name', 'container', 'device']

## Handler

    handler = ({config}) ->

      # note, getting the volume to make sure it exists
      {$status, data} = await @lxc.storage.volume.get
        pool: config.pool
        name: config.name
        type: config.type
      if not $status
        throw new Error('Missing requirement: Volume does not exist.')
      volume = data

      # note, getting the container to make sure it exists
      {$status, data} = await @lxc.query
        path: "/1.0/instances/#{config.container}"
      if not $status
        throw new Error('Missing requirement: Container does not exist.')
      container = data

      switch container.type
        when 'virtual-machine' 
          if volume.content_type == "filesystem" then throw new Error("Type: #{container.type} can only mount block type volumes.")
        when 'container' 
          if volume.content_type == "block" then throw new Error("Type: #{container.type} can only mount filesystem type volumes.")
      if volume.content_type == "filesystem" and not config.path? then throw new Error("Missing requirement: Path is required for filesystem type volumes.")
      parameters = JSON.stringify {
        devices:
          "#{config.device}":
            pool: config.pool
            source: config.name
            type: "disk"
            path: if config.path? then config.path else null
      }

      {$status} = await @lxc.query
        path: "/1.0/instances/#{config.container}"
        request: 'PATCH'
        data: parameters
        wait: true
        format: "string"
        code: [0, 42]
      $status: $status
      
## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
