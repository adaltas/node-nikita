
# `nikita.krb5.ktadd`

Create and manage a keytab. This function is usually not used directly but instead
called by the `krb5.addprinc` function.

## Example

```js
const {$status} = await nikita.krb5.ktadd({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
})
console.info(`keytab was created or updated: ${$status}`)
```
