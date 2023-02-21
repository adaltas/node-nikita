
# `nikita.lxc.file.read`

Read the content of a file in a container.

## Example

```js
const {data} = await nikita.lxc.file.read({
  container: 'my_container',
  target: '/root/a_file'
})
console.info(`File content: ${data}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
          'target':
            type: 'string'
            description: '''
            File destination in the form of "<path>".
            '''
          'trim':
            type: 'boolean'
            default: false
            description: '''
            Trim the file content.
            '''
        required: ['container']

## Handler

    handler = ({config}) ->
      {data} = await @lxc.query
        $header: "Check if file exists in container #{config.container}"
        path: "/1.0/instances/#{config.container}/files?path=#{config.target}"
        format: 'string'
      data = data.trim() if config.trim
      $status: true
      data: data

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
