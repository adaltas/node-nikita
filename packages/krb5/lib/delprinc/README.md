
# `nikita.krb5.delprinc`

Remove a Kerberos principal and optionally its keytab.

## Example

```js
const {$status} = await nikita.krb5.delrinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  admin: {
    principal: 'me/admin@MY_REALM',
    password: 'pass',
    server: 'localhost'
  }
})
console.info(`Principal was removed: ${$status}`)
```
