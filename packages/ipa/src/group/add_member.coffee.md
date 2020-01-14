
# `nikita.ipa.group.add_member`

Add member to a group in FreeIPA.

## Options

* `attributes` (object, required)   
  Attributes associated with the group such as `ipaexternalmember`,
  `no_members`, `user` and `group`.
* `referer` (string, ?required)   
  The HTTP referer of the request, required unless provided inside the `Referer`
  header.
* `cn` (string, required)   
  Name of the group to add.
* `url` (string, required)    
  The IPA HTTP endpoint, for example "https://ipa.domain.com/ipa/session/json"

## Exemple

```js
require("nikita")
.ipa.group.add_member({
  cn: "somegroup",
  attributes: {
    user: ["someone"]
  },
  connection: {
    referer: "https://my.domain.com",
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(){
  console.info(err ? err.message : status ?
    "Group was updated" : "Group was already set")
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
          method: "group_add_member/1"
          params: [[options.cn], options.attributes]
          id: 0
        http_headers: options.http_headers
      , (err, {data}) ->
        return callback err if err
        if data.error
          error = Error data.error.message
          error.code = data.error.code
          return callback error
        callback null, status: true, result: data.result.result

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
