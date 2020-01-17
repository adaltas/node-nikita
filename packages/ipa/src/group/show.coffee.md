
# `nikita.ipa.group.show`

Retrieve group information from FreeIPA.

## Options
 
* `cn` (string, required)   
  Name of the group to add.

## Exemple

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
        'cn': type: 'string'
        'attributes':
          type: 'object'
          properties:
            'user': type: 'array', minItems: 1, uniqueItems: true, items: type: 'string'
        'connection':
          $ref: '/nikita/connection/http'
      required: ['cn', 'connection']

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
          method: "group_show/1"
          params: [[options.cn],{}]
          id: 0
        http_headers: options.http_headers
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
