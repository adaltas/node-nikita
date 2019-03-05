
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
require('nikita')
.ipa.group.add_member({
  cn: 'somegroup',
  attributes: {
    user: ['someone']
  },
  referer: 'https://my.domain.com',
  url: 'https://ipa.domain.com/ipa/session/json',
  principal: 'admin@DOMAIN.COM',
  password: 'XXXXXX'
}, function(){
  console.info(err ? err.message : status ?
    'Group was updated' : 'Group was already set')
})
```

    module.exports = ({options}, callback) ->
      options.http_headers ?= {}
      options.http_headers['Accept'] = 'applicaton/json'
      options.http_headers['Content-Type'] = 'application/json'
      options.http_headers['Referer'] ?= options.referer
      throw Error "Required Option: cn is required, got #{options.cn}" unless options.cn
      throw Error "Required Option: attributes is required, got #{options.attributes}" unless options.attributes
      throw Error "Required Option: url is required, got #{options.url}" unless options.url
      throw Error "Required Option: principal is required, got #{options.principal}" unless options.principal
      throw Error "Required Option: password is required, got #{options.password}" unless options.password
      throw Error "Required Option: referer is required, got #{options.http_headers['Referer']}" unless options.http_headers['Referer']
      @connection.http options,
        negotiate: true
        url: options.url
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

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
