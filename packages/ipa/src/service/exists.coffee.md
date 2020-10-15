
# `nikita.ipa.service.exists`

Check if a service exists inside FreeIPA.

## Example

```js
require('nikita')
.ipa.service.exists({
  principal: 'myprincipal/my.domain.com',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(err, {status, exists}){
  console.info(err ? err.message : status ?
    'Service exists' : 'Service does not exist')
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'principal':
          type: 'string'
          description: """
          Name of the service to check for existence.
          """
        'connection':
          $ref: 'module://@nikitajs/network/src/http'
          required: ['principal', 'password']
      required: ['connection', 'principal']


## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      try
        await @ipa.service.show
          connection: config.connection
          principal: config.principal
        status: true, exists: true
      catch err
        if err.code isnt 4001 # service not found
          throw err
        status: false, exists: false
      

## Export

    module.exports =
      handler: handler
      schema: schema
      shy: true
