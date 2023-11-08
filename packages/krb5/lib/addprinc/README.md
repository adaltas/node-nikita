
# `nikita.krb5.addprinc`

Create a new Kerberos principal with a password or an optional keytab.

## Example

```js
const {$status} = await nikita.krb5.addprinc({
  admin: {
    password: 'pass',
    principal: 'me/admin@MY_REALM',
    server: 'localhost'
  },
  keytab: '/etc/security/keytabs/my.service.keytab',
  gid: 'myservice',
  principal: 'myservice/my.fqdn@MY.REALM',
  randkey: true,
  uid: 'myservice'
})
console.info(`Principal was created or modified: ${$status}`)
```
