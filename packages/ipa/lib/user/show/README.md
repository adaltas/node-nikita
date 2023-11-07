
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
```

If user is missing, error looks like:

```json
{
  code: 4001,
  message: 'missing: user not found'
}
```

If user exists, `result` looks like:

```json
{
  dn: 'uid=admin,cn=users,cn=accounts,dc=nikita,dc=local',
  memberof_group: [ 'admins', 'trust admins' ],
  uid: [ 'admin' ],
  loginshell: [ '/bin/bash' ],
  uidnumber: [ '754600000' ],
  gidnumber: [ '754600000' ],
  has_keytab: true,
  has_password: true,
  sn: [ 'Administrator' ],
  homedirectory: [ '/home/admin' ],
  krbprincipalname: [ 'admin@NIKITA.LOCAL' ],
  nsaccountlock: false
}
```
