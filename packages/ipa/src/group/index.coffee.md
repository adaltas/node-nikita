
# `nikita.ipa.group`

Add or modify a group in FreeIPA.

## Options

* `attributes` (object, required)   
  Attributes associated with the group to add or modify.
* `cn` (string, required)   
  Name of the group to add.

## Exemple

```js
require('nikita')
.ipa.group({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(){
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
      options.attributes ?= {}
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      output = {}
      @ipa.group.exists
        connection: options.connection
        cn: options.cn
      @call ({}, callback) ->
        @connection.http options.connection,
          negotiate: true
          method: 'POST'
          data:
            method: unless @status(-1) then "group_add/1" else "group_mod/1"
            params: [[options.cn], options.attributes]
            id: 0
          http_headers: options.http_headers
        , (error, {data}) ->
          if data?.error
            return callback null, false if data.error.code is 4202 # no modifications to be performed
            error = Error data.error.message
            error.code = data.error.code
          output.result = data.result.result
          callback error, true
      @call
        unless: -> @status -1
      , ->
        @ipa.group.show options,
          cn: options.cn
        , (err, {result}) ->
          output.result = result unless err
      @next (err, {status}) ->
        callback err, status: status, result: output.result

## Export

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    diff = require 'object-diff'
