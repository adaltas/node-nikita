
# `nikita.ipa.user.show`

Retrieve user information from FreeIPA.

## Options

* `attributes` (object, required)    
* `referer` (string, ?required)   
  The HTTP referer of the request, required unless provided inside the `Referer`
  header.
* `uid` (string, required)   
  UID of the user to add, same as the username.
* `username` (string, required)   
  UID of the user to add, alias of `uid`.
* `url` (string, required)    
  The IPA HTTP endpoint, for example "https://ipa.domain.com/ipa/session/json"

## Exemple

```js
require('nikita')
.ipa.user.show({
  uid: 'someone',
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
      options.http_headers['Accept'] = 'applicaton/json'
      options.http_headers['Content-Type'] = 'application/json'
      options.http_headers['Referer'] ?= options.referer
      throw Error "Required Option: uid is required, got #{options.uid}" unless options.uid
      throw Error "Required Option: url is required, got #{options.url}" unless options.url
      throw Error "Required Option: principal is required, got #{options.principal}" unless options.principal
      throw Error "Required Option: password is required, got #{options.password}" unless options.password
      throw Error "Required Option: referer is required, got #{options.http_headers['Referer']}" unless options.http_headers['Referer']
      @connection.http options,
        negotiate: true
        url: options.url
        method: 'POST'
        data:
          method: "user_show/1"
          params: [[options.uid],{}]
          id: 0
        http_headers: options.http_headers
      , (err, {data}) ->
        return callback err if err
        if data.error
          error = Error data.error.message
          error.code = data.error.code
          return callback error
        callback null, result: data.result.result

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
