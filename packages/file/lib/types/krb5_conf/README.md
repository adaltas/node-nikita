
# `nikita.file.types.krb5_conf`

Modify the client Kerberos configuration file located by default in
"/etc/krb5.conf". Kerberos is a network authentication protocol. It is designed
to provide strong authentication for client/server applications by using
secret-key cryptography.

## Example registering a new realm

```js
const {$status} = await nikita.file.types.krb_conf({
  merge: true,
  content: {
    realms: {
      'MY.DOMAIN': {
        kdc: 'ipa.domain.com:88',
        admin_server: 'ipa.domain.com:749',
        default_domain: 'domain.com'
      }
    }
  }
})
console.info(`Configuration was updated: ${$status}`)
```
