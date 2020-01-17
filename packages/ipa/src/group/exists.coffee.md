
# `nikita.ipa.group.exists`

Check if a group exists inside FreeIPA.

## Options

* `cn` (string, required)   
  Name of the group to check for existence.

## Exemple

```js
require('nikita')
.ipa.group.exists({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(err, {status, exists}){
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

    handler = ({options}, callback) ->
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      @ipa.group.show
        connection: options.connection
        cn: options.cn
        relax: true
      , (err) ->
        return callback err if err and err.code isnt 4001
        callback null, status: !err, exists: !err

## Export

    module.exports =
      handler: handler
      schema: schema
      shy: true

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
