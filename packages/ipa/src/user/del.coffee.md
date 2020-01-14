
# `nikita.ipa.user.del`

Delete a user from FreeIPA.

## Options

* `referer` (string, ?required)   
  The HTTP referer of the request, required unless provided inside the `Referer`
  header.
* `uid` (string, required)   
  Name of the user to delete, same as the username.
* `username` (string, required)   
  Name of the user to delete, alias of `uid`.
* `url` (string, required)    
  The IPA HTTP endpoint, for example "https://ipa.domain.com/ipa/session/json"

## Exemple

```js
require("nikita")
.ipa.user.del({
  uid: "someone",
  connection: {
    referer: "https://my.domain.com",
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(){
  console.info(err ? err.message : status ?
    "User was updated" : "User was already set")
})
```

## Options

    on_options = ({options}) ->
      options.uid ?= options.username
      delete options.username

## Schema

    schema =
      type: 'object'
      properties:
        'uid': type: 'string'
        'username': type: 'string'
        'connection':
          $ref: '/nikita/connection/http'
      required: ['connection', 'uid']

## Handler

    handler = ({options}) ->
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      @ipa.user.exists
        connection: options.connection
        shy: false
        uid: options.uid
      @connection.http options.connection,
        if: -> @status(-1)
        negotiate: true
        method: 'POST'
        data:
          method: "user_del/1"
          params: [[options.uid], {}]
          id: 0
        http_headers: options.http_headers

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
