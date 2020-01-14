
# `nikita.ipa.group.del`

Delete a group from FreeIPA.

## Options

* `referer` (string, ?required)   
  The HTTP referer of the request, required unless provided inside the `Referer`
  header.
* `cn` (string, required)   
  Name of the group to delete.
* `url` (string, required)    
  The IPA HTTP endpoint, for example "https://ipa.domain.com/ipa/session/json"

## Exemple

```js
require('nikita')
.ipa.group.del({
  cn: 'somegroup',
  connection: {
    referer: "https://my.domain.com",
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(){
  console.info(err ? err.message : status ?
    'Group was updated' : 'Group was already set')
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

    handler = ({options}) ->
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      @ipa.group.exists
        connection: options.connection
        shy: false
        cn: options.cn
      @connection.http options.connection,
        if: -> @status(-1)
        negotiate: true
        method: 'POST'
        data:
          method: "group_del/1"
          params: [[options.cn], {}]
          id: 0
        http_headers: options.http_headers

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
