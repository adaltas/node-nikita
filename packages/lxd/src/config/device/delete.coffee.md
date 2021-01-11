
# `nikita.lxd.config.delete`

Delete a device from a container

## Callback parameters

* `err`
  Error object if any.
* `result.status`
  True if the device was removed False otherwise.

## Example

```js
const {status} = await nikita.lxd.config.device.delete({
  container: 'container1',
  device: 'root'
})
console.info(`Device was removed: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
        'device':
          type: 'string'
          description: """
          Name of the device in LXD configuration, for example "eth0".
          """
      required: ['container', 'device']

## Handler

    handler = ({config}) ->
      {properties} = await @lxd.config.device.show
        container: config.container
        device: config.device
      return status: false unless properties
      {status} = await @execute
        command: [
          'lxc', 'config', 'device', 'remove'
          config.container
          config.device
        ].join ' '
      status: status

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema
