
# `nikita.ipa.service.exists`

Check if a service exists inside FreeIPA.

## Options

* `principal` (string, required)   
  Name of the service to check for existence.
* `connection` (object, required)   
  See the `nikita.connection.http` action.

## Exemple

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
        'principal': type: 'string'
        'connection':
          $ref: '/nikita/connection/http'
      required: ['connection', 'principal']

    handler = ({options}, callback) ->
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      @ipa.service.show
        connection: options.connection
        principal: options.principal
        relax: true
      , (err) ->
        return callback err if err and err.code isnt 4001
        exists = !err
        callback null, status: exists, exists: exists

## Export

    module.exports =
      handler: handler
      schema: schema
      shy: true

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
