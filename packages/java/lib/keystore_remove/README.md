
# `nikita.java.keystore_remove`

Remove certificates, private keys and certificate authorities from java
keystores and truststores.

## Removing a key and its certificate

```js
const {$status} = await nikita.java.keystore_remove([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate',
  keypass: 'mypassword',
  name: 'node_1'
})
console.info(`Key and its certificate were updated: ${$status}`)
```

## Removing a certificate authority

```js
const {$status} = await nikita.java.keystore_remove([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate'
})
console.info(`Certificate authority was removed: ${$status}`)
```
