
# `nikita.java.keystore_remove(options, [callback])`

Remove certificates, private keys and certificate authorities from java
keystores and trustores.

## Options

* `name` (string|array)   
  Alias of the key and the certificate, required if "caname" isn't provided.   
* `caname` (string|array)   
  Alias of the certificate authority (CA), required if "name" isn't provided.   
* `keystore` (string)   
  Path to the keystore (doesn't need to exists).   
* `storepass` (string)   
  Password to manage the keystore.   

## Removing a key and its certificate

```js
require('nikita').java.keystore_remove([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate',
  keypass: 'mypassword',
  name: 'node_1'
}, function(err, status){ /* do sth */ });
```

## Removing a certificate authority

```js
require('nikita').java.keystore_add([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate'
}, function(err, status){ /* do sth */ });
```
## Source Code

    module.exports = (options) ->
      throw Error "Required option 'keystore'" unless options.keystore
      throw Error "Required option 'storepass'" unless options.storepass
      throw Error "Required option 'name' or 'caname'" unless options.name or options.caname
      options.caname = [options.caname] unless Array.isArray options.caname
      options.name = [options.name] unless Array.isArray options.name
      aliases = [options.caname..., options.name...].join(' ').trim()
      @system.execute
        bash: true
        cmd: """
        test -f "#{options.keystore}" || # Nothing to do if not a file
        exit 3
        count=0
        for alias in #{aliases}; do
          if keytool -list -keystore "#{options.keystore}" -storepass "#{options.storepass}" -alias "$alias"; then
             keytool -delete -keystore "#{options.keystore}" -storepass "#{options.storepass}" -alias "$alias"
             (( count++ ))
          fi
        done
        [ $count -eq 0 ] && exit 3
        exit 0
        """
        code_skipped: 3
