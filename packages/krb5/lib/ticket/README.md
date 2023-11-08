
# `nikita.krb5.ticket`

Renew the Kerberos ticket of a user principal inside a Unix session.

## Example

```js
const {$status} = await nikita.krb5.ticket({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
})
console.info(`ticket was renewed: ${$status}`)
```
