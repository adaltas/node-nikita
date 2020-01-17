
# `nikita.ipa.user`

Add or modify a user in FreeIPA.

## Options

* `attributes` (object, required)   
  Attributes associated with the user to add or modify.
* `uid` (string, required)   
  Name of the user to add, same as the username.
* `username` (string, required)   
  Name of the user to add, alias of `uid`.

## Exemple

```js
require('nikita')
.ipa.user({
  uid: "someone",
  attributes: {
    noprivate: true,
    gidnumber: 1000,
    userpassword: "secret"
  },
  connection: {
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
        'attributes':
          type: 'object'
          properties:
            'givenname': type: 'string' # Firstname
            'sn': type: 'string' # Lastname
            'mail': type: 'array', minItems: 1, uniqueItems: true, items: type: 'string'
        'connection':
          $ref: '/nikita/connection/http'
      required: ['attributes', 'connection', 'uid']

## Handler

    handler = ({options}, callback) ->
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      @ipa.user.exists
        connection: options.connection
        uid: options.uid
      @call ({}, callback) ->
        @connection.http options.connection,
          negotiate: true
          method: 'POST'
          data:
            method: unless @status(-1) then 'user_add/1' else 'user_mod/1'
            params: [[options.uid], options.attributes]
            id: 0
        , (error, {data}) ->
          if data?.error
            return callback null, false if data.error.code is 4202 # no modifications to be performed
            error = Error data.error.message
            error.code = data.error.code
          callback error, true
      @next callback

## Exports

    module.exports =
      handler: handler
      on_options: on_options
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
