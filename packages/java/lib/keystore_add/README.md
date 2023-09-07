
# `nikita.java.keystore_add`

Add certificates, private keys and certificate authorities to java keystores
and truststores.

## CA Cert Chains

In case the CA file reference a chain of certificates, each certificate will be
referenced by a unique incremented alias, starting at 0. For example if the 
alias value is "my-alias", the aliases will be "my-alias-0" then "my-alias-1"... 

## Relevant Java properties

* `javax.net.ssl.trustStore`
* `javax.net.ssl.trustStorePassword`
* `javax.net.ssl.keyStore`
* `javax.net.ssl.keyStoreType`
* `javax.net.ssl.keyStorePassword`

## Relevant commands

* View the content of a Java KeyStore (JKS) and Java TrustStore:   
  `keytool -list -v -keystore $keystore -storepass $storepass`   
  `keytool -list -v -keystore $keystore -storepass $storepass -alias $caname`   
  Note, alias is optional and may reference a CA or a certificate
* View the content of a ".pem" certificate:   
  `openssl x509 -in cert.pem -text`   
  `keytool -printcert -file certs.pem`   
* Change the password of a keystore:   
  `keytool -storepasswd -keystore my.keystore`
* Change the key's password:   
  `keytool -keypasswd -alias <key_name> -keystore my.keystore`

## Uploading public and private keys into a keystore

```js
const {$status} = await nikita.java.keystore_add([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate',
  cacert: '/tmp/cacert.pem',
  key: "/tmp/private_key.pem",
  cert: "/tmp/public_cert.pem",
  keypass: 'mypassword',
  name: 'node_1'
})
console.info(`Keystore was updated: ${$status}`)
```

## Uploading a certificate authority

```js
const {$status} = await nikita.java.keystore_add([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate',
  cacert: '/tmp/cacert.pem'
})
console.info(`Keystore was updated: ${$status}`)
```

## Requirements

This action relies on the `openssl` and `keytool` commands. If not detected
from the path, Nikita will look for "/usr/java/default/bin/keytool" which is the
default location of the Oracle JDK installation.
