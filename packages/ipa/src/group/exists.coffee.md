
# `nikita.ipa.group.exists`

Check if a group exists inside FreeIPA.

## Options

* `referer` (string, ?required)   
  The HTTP referer of the request, required unless provided inside the `Referer`
  header.
* `cn` (string, required)   
  Name of the group to check for existence.
* `url` (string, required)    
  The IPA HTTP endpoint, for example "https://ipa.domain.com/ipa/session/json"

## Exemple

```js
require('nikita')
.ipa.group.exists({
  cn: 'somegroup',
  referer: 'https://my.domain.com',
  url: 'https://ipa.domain.com/ipa/session/json',
  principal: 'admin@DOMAIN.COM',
  password: 'XXXXXX'
}, function(err, {status, exists}){
  console.info(err ? err.message : status ?
    'Group was updated' : 'Group was already set')
})
```

    module.exports = shy: true, handler: ({options}, callback) ->
      options.http_headers ?= {}
      options.http_headers['Accept'] ?= 'applicaton/json'
      options.http_headers['Referer'] ?= options.referer
      throw Error "Required Option: cn is required, got #{options.cn}" unless options.cn
      throw Error "Required Option: url is required, got #{options.url}" unless options.url
      throw Error "Required Option: principal is required, got #{options.principal}" unless options.principal
      throw Error "Required Option: password is required, got #{options.password}" unless options.password
      throw Error "Required Option: referer is required, got #{options.http_headers['Referer']}" unless options.http_headers['Referer']
      @ipa.group.show options,
        cn: options.cn
        relax: true
      , (err) ->
        return callback err if err and err.code isnt 4001
        exists = !err
        callback null, status: exists, exists: exists
      
        
## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
