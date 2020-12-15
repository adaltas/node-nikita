
# `nikita.ipa.user.show`

Retrieve user information from FreeIPA.

## Example

```js
const {result} = await nikita.ipa.user.show({
  uid: "someone",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User is ${result.uid[0]}`)

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
```

## Hooks

    on_action = ({config}) ->
      config.uid ?= config.username
      delete config.username

## Schema

    schema =
      type: 'object'
      properties:
        'uid':
          type: 'string'
          description: """
          Name of the user to show, same as the `username`.
          """
        'username':
          type: 'string'
          description: """
          Name of the user to show, alias of `uid`.
          """
        'connection':
          $ref: 'module://@nikitajs/network/src/http'
          required: ['principal', 'password']
      required: ['connection', 'uid']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {data} = await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: 'user_show/1'
          params: [[config.uid],{}]
          id: 0
      if data.error
        error = Error data.error.message
        error.code = data.error.code
        throw error
      else
        result: data.result.result

## Export

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema
