
# `nikita.ipa.service.del`

Delete a service from FreeIPA.

## Example

```js
require("nikita")
.ipa.service.del({
  principal: "myprincipal/my.domain.com",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(){
  console.info(err ? err.message : status ?
    "Service deleted" : "Service does not exist")
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'principal':
          type: 'string'
          description: """
          Name of the service to delete.
          """
        'connection':
          $ref: 'module://@nikitajs/network/src/http'
          required: ['principal', 'password']
      required: ['connection', 'principal']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {status} = await @ipa.service.exists
        connection: config.connection
        shy: false
        principal: config.principal
      return unless status
      @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: "service_del/1"
          params: [[config.principal], {}]
          id: 0

## Export

    module.exports =
      handler: handler
      schema: schema
