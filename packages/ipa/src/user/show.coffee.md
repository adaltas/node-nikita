
# `nikita.ipa.user.show`

Retrieve user information from FreeIPA.

## Options

* `uid` (string, required)   
  Name of the user to add, same as the username.
* `username` (string, required)   
  Name of the user to add, alias of `uid`.

## Exemple

```js
require("nikita")
.ipa.user.show({
  uid: "someone",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
}, function(err, {result}){
  console.info(err ? err.message :
    `User is ${result.uid[0]}`)
  // If user is missing, `err` looks like:
  // { code: 4001
  // message: 'missing: user not found' }
  // If user exists, `result` looks like:
  // { dn: 'uid=admin,cn=users,cn=accounts,dc=nikita,dc=local',
  // memberof_group: [ 'admins', 'trust admins' ],
  // uid: [ 'admin' ],
  // loginshell: [ '/bin/bash' ],
  // uidnumber: [ '754600000' ],
  // gidnumber: [ '754600000' ],
  // has_keytab: true,
  // has_password: true,
  // sn: [ 'Administrator' ],
  // homedirectory: [ '/home/admin' ],
  // krbprincipalname: [ 'admin@NIKITA.LOCAL' ],
  // nsaccountlock: false }
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

    handler = ({options}, callback) ->
      options.connection.http_headers ?= {}
      options.connection.http_headers['Referer'] ?= options.connection.referer or options.connection.url
      throw Error "Required Option: principal is required, got #{options.connection.principal}" unless options.connection.principal
      throw Error "Required Option: password is required, got #{options.connection.password}" unless options.connection.password
      @connection.http options.connection,
        negotiate: true
        method: 'POST'
        data:
          method: 'user_show/1'
          params: [[options.uid],{}]
          id: 0
      , (err, {data}) ->
        return callback err if err
        if data.error
          error = Error data.error.message
          error.code = data.error.code
          return callback error
        callback null, result: data.result.result

## Export

    module.exports =
      handler: handler
      on_options: on_options
      schema: schema

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
