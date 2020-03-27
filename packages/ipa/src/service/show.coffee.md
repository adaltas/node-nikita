
# `nikita.ipa.service.show`

Retrieve service information from FreeIPA.

## Options

* `principal` (string, required)   
  Name of the service to add.

## Exemple

```js
require("nikita")
.ipa.service.show({
  principal: "myprincipal/my.domain.com",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(err, {result}){
  console.info(err ? err.message :
    `Service is ${result.principal[0]}`)
}
switch(err.code){
  case 4001:
   assert("missing: service not found", err.message)
  break
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'principal': type: 'string'
        'connection':
          $ref: '/nikita/connection/http'
      required: ['connection', 'principal']

## Handler

    handler = ({options}, callback) ->
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      @connection.http options.connection,
        negotiate: true
        method: 'POST'
        data:
          method: 'service_show/1'
          params: [[options.principal],{}]
          id: 0
      , (err, {data}) ->
        return callback err if err
        if data.error
          error = Error data.error.message
          error.code = data.error.code
          return callback error
        callback null, result: data.result.result

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
