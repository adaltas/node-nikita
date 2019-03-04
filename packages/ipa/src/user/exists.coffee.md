
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
  referer: 'https://my.domain.com',
  url: 'https://ipa.domain.com/ipa/session/json',
  principal: 'admin@DOMAIN.COM',
  password: 'XXXXXX'
}, function(err, {status, exists}){
  console.info(err ? err.message : status ?
    'User was updated' : 'User was already set')
})
```

    module.exports = shy: true, handler: ({options}, callback) ->
      options.uid ?= options.username
      options.http_headers ?= {}
      options.http_headers['Accept'] ?= 'applicaton/json'
      options.http_headers['Referer'] ?= options.referer
      throw Error "Required Option: uid is required, got #{options.uid}" unless options.uid
      throw Error "Required Option: url is required, got #{options.url}" unless options.url
      throw Error "Required Option: principal is required, got #{options.principal}" unless options.principal
      throw Error "Required Option: password is required, got #{options.password}" unless options.password
      throw Error "Required Option: referer is required, got #{options.http_headers['Referer']}" unless options.http_headers['Referer']
      @ipa.user.show options,
        uid: options.uid
        relax: true
      , (err, {result}) ->
        return callback err if err and err.code isnt 4001
        exists = !err
        callback null, status: exists, exists: exists
      
        
## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
