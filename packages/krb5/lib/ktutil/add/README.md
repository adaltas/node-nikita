
# `nikita.krb5.ktutil.add`

Create and manage a keytab for an existing principal. It's different than ktadd
in the way it can manage several principal on one keytab.

## Example

```js
const {$status} = await nikita.krb5.ktutil.add({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  password: 'password'
})
console.info(`Keytab was created or modified: ${$status}`)
```

## Note, fields in 'getprinc -terse' output

- princ-canonical-name
- princ-exp-time
- last-pw-change
- pw-exp-time
- princ-max-life
- modifying-princ-canonical-name
- princ-mod-date
- princ-attributes <=== This is the field you want
- princ-kvno
- princ-mkvno
- princ-policy (or 'None')
- princ-max-renewable-life
- princ-last-success
- princ-last-failed
- princ-fail-auth-count
- princ-n-key-data
- ver
- kvno
- data-type[0]
- data-type[1]
