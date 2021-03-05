
# `nikita.lxd.query`

Send a raw query to LXD.

## Example

```js
const {$status} = await nikita.lxd.init({
  image: "ubuntu:18.04",
  container: "my_container"
})
console.info(`Container was created: ${$status}`)
```

## TODO

The `lxc query` command comes with a few flag which we shall support:

```
Flags:
  -d, --data      Input data
      --raw       Print the raw response
  -X, --request   Action (defaults to GET) (default "GET")
      --wait      Wait for the operation to complete
```

## Schema

    schema =
      type: 'object'
      properties:
        'path':
          type: 'string'
          description: """
          The API path in the form of `[<remote>:]<API path>`, for example
          `/1.0/instances/c1`
          """

## Handler

    handler = ({config}) ->
      {stdout} = await @execute
        command: [
          'lxc', 'query', config.path
        ].join ' '
      $status: true
      data: JSON.parse stdout

## Exports

    module.exports =
      handler: handler
      metadata:
        schema: schema
        shy: true
