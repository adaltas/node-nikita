
# `nikita.java.keystore_add`

Add certificates, private keys and certificate authorities to java keystores
and truststores.

## Options

* `name` (string)   
  Name of the certificate, required if a certificate is provided.
* `caname` (string)   
  Name of the certificate authority (CA), required.
* `cacert` (string)   
  Path to the certificate authority (CA), required.
* `local` (boolean)    
  treat the source file (key, cert or cacert) as a local file present on the 
  host, only apply with remote actions over SSH, default is "false".
* `openssl` (string)   
  Path to OpenSSl command line tool, default to "openssl".
* `parent` (boolean|object)   
  Create parent directory with provided options if an object or default 
  system options if "true".
* `storepass` (string)   
  Password to manage the keystore.
* `tmpdir` (string)   
  Temporary directory used to isolate certificate from their container file as
  well as to store uploaded file when the option `local`
  is "true"; default to "/tmp/nikita/java_keystore_#{Date.now()}". 

## Callback parameters

* `err` (object|null)   
  Error object if any.
* `status` (boolean)   
  Indicates if the certificated was inserted.

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
require('nikita')
.java.keystore_add([{
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
require('nikita')
.java.keystore_add([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate',
  cacert: '/tmp/cacert.pem'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering java.keystore_add", level: 'DEBUG', module: 'nikita/lib/java/keystore_add'
      ssh = @ssh options.ssh
      p = if ssh then path.posix else path
      # Validate options
      throw Error "Required Option: 'keystore'" unless options.keystore
      throw Error "Required Option: 'storepass'" unless options.storepass
      throw Error "Required Options: 'cacert' or 'cert'" unless options.cacert or options.cert
      throw Error "Required Option: 'key' for certificate" if options.cert and not options.key
      throw Error "Required Option: 'keypass' for certificate" if options.cert and not options.keypass
      throw Error "Required Option: 'name' for certificate" if options.cert and not options.name
      # Default options
      options.parent ?= {}
      options.openssl ?= 'openssl'
      options.tmpdir ?= "/tmp/nikita/java_keystore_#{Date.now()}"
      # Update paths in case of download
      files =
        cert: if ssh and options.local and options.cert? then  "#{options.tmpdir}/#{path.basename options.cert}" else options.cert
        cacert: if ssh and options.local and options.cacert? then  "#{options.tmpdir}/#{path.basename options.cacert}" else options.cacert
        key: if ssh and options.local and options.key? then  "#{options.tmpdir}/#{path.basename options.key}" else options.key
      # Temporary directory
      # Used to upload certificates and to isolate certificates from their file
      @system.mkdir
        if: options.tmpdir
        target: "#{options.tmpdir}"
        mode: 0o0700
        shy: true
      # Upload certificates
      @file.download
        if: ssh and options.local and options.cacert
        source: options.cacert
        target: files.cacert
        mode: 0o0600
        shy: true
      @file.download
        if: ssh and options.local and options.cert
        source: options.cert
        target: files.cert
        mode: 0o0600
        shy: true
      @file.download
        if: ssh and options.local and options.key
        source: options.key
        target: files.key
        mode: 0o0600
        shy: true
      # Prepare parent directory
      @system.mkdir options, options.parent,
        # header: null
        unless_exists: true
        target: p.dirname options.keystore
      # Deal with key and certificate
      @system.execute
        if: !!options.cert
        bash: true
        cmd: """
        cleanup () {
          [ -n "#{if options.cacert then '1' else ''}" ] || rm -rf #{options.tmpdir};
        }
        if ! which #{options.openssl}; then echo 'OpenSSL command line tool not detected'; cleanup; exit 4; fi
        [ -f #{files.cert} ] || (cleanup; exit 6)
        # mkdir -p -m 700 #{options.tmpdir}
        user=`#{options.openssl} x509  -noout -in "#{files.cert}" -sha1 -fingerprint | sed 's/\\(.*\\)=\\(.*\\)/\\2/' | cat`
        # We are only retrieving the first certificate found in the chain with `head -n 1`
        keystore=`keytool -list -v -keystore #{options.keystore} -storepass #{options.storepass} -alias #{options.name} | grep SHA1: | head -n 1 | sed -E 's/.+SHA1: +(.*)/\\1/'`
        echo "User Certificate: $user"
        echo "Keystore Certificate: $keystore"
        if [ "$user" = "$keystore" ]; then cleanup; exit 5; fi
        # Create a PKCS12 file that contains key and certificate
        #{options.openssl} pkcs12 -export \
          -in "#{files.cert}" -inkey "#{files.key}" \
          -out "#{options.tmpdir}/pkcs12" -name #{options.name} \
          -password pass:#{options.keypass}
        # Import PKCS12 into keystore
        keytool -noprompt -importkeystore \
          -destkeystore #{options.keystore} \
          -deststorepass #{options.storepass} \
          -destkeypass #{options.keypass} \
          -srckeystore "#{options.tmpdir}/pkcs12" -srcstoretype PKCS12 -srcstorepass #{options.keypass} \
          -alias #{options.name}
        """
        trap: true
        code_skipped: 5 # OpenSSL exit 3 if file does not exists
      , (err) ->
        throw Error "OpenSSL command line tool not detected" if err?.code is 4
        throw Error "Keystore file does not exists" if err?.code is 6
      # Deal with CACert
      @system.execute
        if: options.cacert
        bash: true
        cmd: """
        # cleanup () { rm -rf #{options.tmpdir}; }
        cleanup () { echo 'clean'; }
        # Check password
        if [ -f #{options.keystore} ] && ! keytool -list -keystore #{options.keystore} -storepass #{options.storepass} >/dev/null; then
          # Keystore password is invalid, change it manually with:
          # keytool -storepasswd -keystore #{options.keystore} -storepass ${old_pasword} -new #{options.storepass}
          cleanup; exit 2
        fi
        [ -f #{files.cacert} ] || (echo 'CA file doesnt not exists: #{files.cacert} 1>&2'; cleanup; exit 3)
        # Import CACert
        PEM_FILE=#{files.cacert}
        CERTS=$(grep 'END CERTIFICATE' $PEM_FILE| wc -l)
        code=5
        for N in $(seq 0 $(($CERTS - 1))); do
          if [ $CERTS -eq '1' ]; then
            ALIAS="#{options.caname}"
          else
            ALIAS="#{options.caname}-$N"
          fi
          # Isolate cert into a file
          CACERT_FILE=#{options.tmpdir}/$ALIAS
          cat $PEM_FILE | awk "n==$N { print }; /END CERTIFICATE/ { n++ }" > $CACERT_FILE
          # Read user CACert signature
          user=`#{options.openssl} x509  -noout -in "$CACERT_FILE" -sha1 -fingerprint | sed 's/\\(.*\\)=\\(.*\\)/\\2/'`
          # Read registered CACert signature
          keystore=`keytool -list -v -keystore #{options.keystore} -storepass #{options.storepass} -alias $ALIAS | grep SHA1: | sed -E 's/.+SHA1: +(.*)/\\1/'`
          echo "User CA Cert: $user"
          echo "Keystore CA Cert: $keystore"
          if [ "$user" = "$keystore" ]; then echo 'Identical Signature'; code=5; continue; fi
          # Remove CACert if signature doesnt match
          if [ "$keystore" != "" ]; then
            keytool -delete \
              -keystore #{options.keystore} \
              -storepass #{options.storepass} \
              -alias $ALIAS
          fi
          keytool -noprompt -import -trustcacerts -keystore #{options.keystore} -storepass #{options.storepass} -alias $ALIAS -file #{options.tmpdir}/$ALIAS
          code=0
        done
        cleanup
        exit $code
        """
        trap: true
        code_skipped: 5
      , (err) ->
        throw Error "CA file does not exist: #{files.cacert}" if err?.code is 3
      # Ensure ownerships and permissions
      @system.chown
        target: options.keystore
        uid: options.uid
        gid: options.gid
        if: options.uid? or options.gid?
      @system.chmod
        target: options.keystore
        mode: options.mode
        if: options.mode?
      # Cleanup
      @system.remove
        shy: true
        always: true # TODO: not yet implemented
        target: "#{options.tmpdir}"

## Dependencies

    path = require('path').posix
