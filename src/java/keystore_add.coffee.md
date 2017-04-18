
# `nikita.java.keystore_add(options, [callback])`

Add certificates, private keys and certificate authorities to java keystores
and trustores.

## Options

*   `name` (string)   
    Name of the certificate, required if a certificate is provided.   
*   `caname` (string)   
    Name of the certificate authority (CA), required.   
*   `cacert` (string)   
    Path to the certificate authority (CA), required.   
*   `openssl` (string)   
    Path to OpenSSl command line tool, default to "openssl".   
*   `storepass` (string)   
    Password to manage the keystore.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Callback parameters

*   `err` (object|null)   
    Error object if any.   
*   `status` (boolean)   
    Indicates if the certificated was inserted.   

## Relevant Java properties

*   `javax.net.ssl.trustStore`
*   `javax.net.ssl.trustStorePassword`
*   `javax.net.ssl.keyStore`
*   `javax.net.ssl.keyStoreType`
*   `javax.net.ssl.keyStorePassword`

## Relevant commands

*   View the content of a Java KeyStore (JKS) and Java TrustStore:
   `keytool -list -v -keystore $keystore -storepass $storepass` -alias $caname
    Note, alias is optional and may reference a CA or a certificate
*   View the content of a ".pem" certificate:
    `openssl x509 -in cert.pem -text`
*   Change the password of a keystore:   
    `keytool -storepasswd -keystore my.keystore`
*   Change the key's password:   
    `keytool -keypasswd -alias <key_name> -keystore my.keystore`

## Uploading public and private keys into a keystore

```js
require('nikita').java.keystore_add([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate',
  cacert: '/tmp/cacert.pem',
  key: "/tmp/private_key.pem",
  cert: "/tmp/public_cert.pem",
  keypass: 'mypassword',
  name: 'node_1'
}, function(err, status){ /* do sth */ });
```

## Uploading a certificate authority

```js
require('nikita').java.keystore_add([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate',
  cacert: '/tmp/cacert.pem'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      throw Error "Required option 'keystore'" unless options.keystore
      throw Error "Required option 'storepass'" unless options.storepass
      throw Error "Required option 'key' for certificate" if options.cert and not options.key
      throw Error "Required option 'keypass' for certificate" if options.cert and not options.keypass
      throw Error "Required option 'name' for certificate" if options.cert and not options.name
      throw Error "Required option 'caname'" unless options.caname
      throw Error "Required option 'cacert'" unless options.cacert
      options.openssl ?= 'openssl'
      tmp_location = "/tmp/nikita/java_keystore_#{Date.now()}"
      files =
        cert: if options.cert? and options.local then  "#{tmp_location}/#{path.basename options.cert}" else options.cert
        cacert: if options.local then  "#{tmp_location}/#{path.basename options.cacert}" else options.cacert
        key: if options.key? and options.local then  "#{tmp_location}/#{path.basename options.key}" else options.key
      @system.mkdir
        target: "#{tmp_location}"
        mode: 0o0700
        shy: true
      @file.download
        if: options.local and options.cacert
        source: options.cacert
        target: files.cacert
        mode: 0o0600
        shy: true
      @file.download
        if: options.local and options.cert
        source: options.cert
        target: files.cert
        mode: 0o0600
        shy: true
      @file.download
        if: options.local and options.key
        source: options.key
        target: files.key
        mode: 0o0600
        shy: true
      @system.execute # Deal with key and certificate
        bash: true
        cmd: """
        if ! which #{options.openssl}; then echo 'OpenSSL command line tool not detected'; exit 4; fi
        # mkdir -p -m 700 #{tmp_location}
        user=`#{options.openssl} x509  -noout -in "#{files.cert}" -md5 -fingerprint | sed 's/\\(.*\\)=\\(.*\\)/\\2/' | cat`
        keystore=`keytool -list -v -keystore #{options.keystore} -alias #{options.name} -storepass #{options.storepass} | grep MD5: | sed -E 's/.+MD5: +(.*)/\\1/'`
        echo "User Certificate: $user"
        echo "Keystore Certificate: $keystore"
        if [[ "$user" == "$keystore" ]]; then exit 3; fi
        # Create a PKCS12 file that contains key and certificate
        #{options.openssl} pkcs12 -export \
          -in "#{files.cert}" -inkey "#{files.key}" \
          -out "#{tmp_location}/pkcs12" -name #{options.name} \
          -password pass:#{options.keypass}
          #-CAfile "#{tmp_location}/cacert" -caname #{options.caname} \
        # Import PKCS12 into keystore
        keytool -noprompt -importkeystore \
          -destkeystore #{options.keystore} \
          -deststorepass #{options.storepass} \
          -destkeypass #{options.keypass} \
          -srckeystore "#{tmp_location}/pkcs12" -srcstoretype PKCS12 -srcstorepass #{options.keypass} \
          -alias #{options.name}
        """
        trap: true
        if: !!options.cert
        code_skipped: 3
      , (err) ->
        throw Error "OpenSSL command line tool not detected" if err?.code is 4
      @system.execute # Deal with CACert
        bash: true
        cmd: """
        cleanup () { rm -rf #{tmp_location}; }
        # Check password
        if [ -f #{options.keystore} ] && ! keytool -list -keystore #{options.keystore} -storepass #{options.storepass} >/dev/null; then
          # Keystore password is invalid, change it manually with:
          # keytool -storepasswd -keystore #{options.keystore} -storepass #{options.storepass}
          cleanup; exit 2
        fi
        # Read user CACert signature
        user=`#{options.openssl} x509  -noout -in "#{files.cacert}" -md5 -fingerprint | sed 's/\\(.*\\)=\\(.*\\)/\\2/'`
        # Read registered CACert signature
        keystore=`keytool -list -v -keystore #{options.keystore} -alias #{options.caname} -storepass #{options.storepass} | grep MD5: | sed -E 's/.+MD5: +(.*)/\\1/'`
        echo "User CACert: $user"
        echo "Keystore CACert: $keystore"
        if [[ "$user" == "$keystore" ]]; then exit 3; fi
        # Remove CACert if signature doesnt match
        if [[ "$keystore" != "" ]]; then
          keytool -delete \
            -keystore #{options.keystore} \
            -storepass #{options.storepass} \
            -alias #{options.caname}
        fi
        # Import CACert
        keytool -noprompt -importcert \
          -keystore #{options.keystore} \
          -storepass #{options.storepass} \
          -alias #{options.caname} \
          -file #{files.cacert}
        """
        # trap: true
        code_skipped: 3
      @system.remove
        target: "#{tmp_location}"
        shy: true
      @system.chown
        target: options.keystore
        uid: options.uid
        gid: options.gid
        if: options.uid? or options.gid?
      @system.chmod
        target: options.keystore
        mode: options.mode
        if: options.mode?

## Dependencies

    path = require 'path'
