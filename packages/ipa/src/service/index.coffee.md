
# `nikita.ipa.service`

Add a service in FreeIPA.

## Example

```js
require('nikita')
.ipa.service({
  principal: "myprincipal/my.domain.com"
  },
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(){
  console.info(err ? err.message : status ?
    "Service was updated" : " Service was already set")
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'principal':
          type: 'string'
          description: """
          Name of the service to add.
          """
        'connection':
          $ref: 'module://@nikitajs/network/src/http'
          required: ['principal', 'password']
      required: ['connection', 'principal']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      # @ipa.service.exists
      #   connection: config.connection
      #   principal: config.principal
      status = true
      {data} = await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: "service_add/1"
          params: [[config.principal], {}]
          id: 0
      if data?.error
        if data.error.code isnt 4002 # principal alredy exists
          error = Error data.error.message
          error.code = data.error.code
          throw error
        status = false
      status: status

## Exports

    module.exports =
      handler: handler
      schema: schema
