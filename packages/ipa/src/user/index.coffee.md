
# `nikita.ipa.user`

Add or modify a user in FreeIPA.

## Options

* `attributes` (object, required)   
  Attributes associated with the user to add or modify.
* `referer` (string, ?required)   
  The HTTP referer of the request, required unless provided inside the `Referer`
  header.
* `uid` (string, required)   
  Name of the user to add, same as the username.
* `username` (string, required)   
  Name of the user to add, alias of `uid`.
* `url` (string, required)    
  The IPA HTTP endpoint, for example "https://ipa.domain.com/ipa/session/json"

## Exemple

```js
require('nikita')
.ipa.user({
  uid: 'someone',
  attributes: {
    noprivate: true,
    gidnumber: 1000,
    userpassword: 'secret'
  },
  referer: 'https://my.domain.com',
  url: 'https://ipa.domain.com/ipa/session/json',
  principal: 'admin@DOMAIN.COM',
  password: 'XXXXXX'
}, function(){
  console.info(err ? err.message : status ?
    'User was updated' : 'User was already set')
})
```

    module.exports = ({options}, callback) ->
      options.uid ?= options.username
      options.http_headers ?= {}
      options.http_headers['Accept'] ?= 'applicaton/json'
      options.http_headers['Referer'] ?= options.referer
      throw Error "Required Option: uid is required, got #{options.uid}" unless options.uid
      throw Error "Required Option: url is required, got #{options.url}" unless options.url
      throw Error "Required Option: principal is required, got #{options.principal}" unless options.principal
      throw Error "Required Option: password is required, got #{options.password}" unless options.password
      throw Error "Required Option: referer is required, got #{options.http_headers['Referer']}" unless options.http_headers['Referer']
      @ipa.user.exists options,
        uid: options.uid
      @call ({}, callback) ->
        @connection.http options,
          negotiate: true
          url: options.url
          method: 'POST'
          data:
            method: unless @status(-1) then "user_add/1" else "user_mod/1"
            params: [[options.uid], options.attributes]
            id: 0
          http_headers: options.http_headers
        , (error, {data}) ->
          if data?.error
            return callback null, false if data.error.code is 4202 # no modifications to be performed
            error = Error data.error.message
            error.code = data.error.code
          callback error, true
      @next callback
      
        
## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
