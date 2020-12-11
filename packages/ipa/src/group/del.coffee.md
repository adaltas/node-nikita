
# `nikita.ipa.group.del`

Delete a group from FreeIPA.

## Example

```js
const {status} = await nikita.ipa.group.del({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Group was deleted: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        'cn':
          type: 'string'
          description: """
          Name of the group to delete.
          """
        'connection':
          $ref: 'module://@nikitajs/network/src/http'
          required: ['principal', 'password']
      required: ['cn', 'connection']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {status} = await @ipa.group.exists
        connection: config.connection
        metadata: shy: false
        cn: config.cn
      return unless status
      @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: "group_del/1"
          params: [[config.cn], {}]
          id: 0

## Export

    module.exports =
      handler: handler
      schema: schema
