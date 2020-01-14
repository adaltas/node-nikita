
# `nikita.ipa.user.exists`

Check if a user exists inside FreeIPA.

## Options

* `referer` (string, ?required)   
  The HTTP referer of the request, required unless provided inside the `Referer`
  header.
* `uid` (string, required)   
  Name of the user to check for existence, same as the username.
* `username` (string, required)   
  Name of the user to add, alias of `uid`.
* `url` (string, required)    
  The IPA HTTP endpoint, for example "https://ipa.domain.com/ipa/session/json"

## Exemple

```js
require('nikita')
.ipa.user.exists({
  uid: 'someone',
  connection: {
    referer: "https://my.domain.com",
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(err, {status, exists}){
  console.info(err ? err.message : status ?
    'User was updated' : 'User was already set')
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

    handler = ({options}, callback) ->
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      @ipa.user.show
        connection: options.connection
        uid: options.uid
        relax: true
      , (err) ->
        return callback err if err and err.code isnt 4001
        exists = !err
        callback null, status: exists, exists: exists

## Export

    module.exports =
      handler: handler
      on_options: on_options
      schema: schema
      shy: true

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
