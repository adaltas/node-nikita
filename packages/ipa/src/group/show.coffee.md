
# `nikita.ipa.group.show`

Retrieve group information from FreeIPA.

## Example

```js
require('nikita')
.ipa.group.show({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(err, {result}){
  console.info(err ? err.message :
    `Group is ${result.cn[0]}`)
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'cn':
          type: 'string'
          description: """
          Name of the group to show.
          """
        'connection':
          $ref: 'module://@nikitajs/network/src/http'
          required: ['principal', 'password']
      required: ['cn', 'connection']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {data} = await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: "group_show/1"
          params: [[config.cn],{}]
          id: 0
      if data.error
        error = Error data.error.message
        error.code = data.error.code
        throw error
      else
        result: data.result.result

## Export

    module.exports =
      handler: handler
      schema: schema
