
# `nikita.lxc.list`

List the networks managed by LXD.

## Example

```js
const { list } = await nikita.lxc.network.list();
console.info(`LXD networks: ${list}`);
```

## Schema definitions

    definitions = {}

## Handler

    handler = ({config}) ->
      {data} = await @lxc.query
        path: "/1.0/networks"
      $status: true
      list: (i.split('/').pop() for i in data)

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
