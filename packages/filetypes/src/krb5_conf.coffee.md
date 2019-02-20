
`nikita.file.types.krb5_conf`

Modify the client Kerberos configuration file located by default in
"/etc/krb5.conf". Kerberos is a network authentication protocol. It is designed
to provide strong authentication for client/server applications by using
secret-key cryptography.

## Options

* `rootdir` (string, optional, undefined)   
  Path to the mount point corresponding to the root directory, optional.
* `backup` (string|boolean, optional, false)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `clean` (boolean, optional, false)   
  Remove all the lines whithout a key and a value, default to "true".
* `content` (object, required)   
  Object to stringify.
* `merge` (boolean, optional, false)   
  Read the target if it exists and merge its content.
* `target` (string, optional, "/etc/krb5.conf")   
  Destination file.

## Example registering a new realm

```js
require('nikita')
.file.types.krb_conf({
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
}, function(err, {status}){
  console.info( err ? err.message : status
    ? 'Configuration was updated'
    : 'No change occured' )
})
```

## Source Code


    module.exports = ({options}) ->
      @log message: "Entering file.types.krb5_conf", level: 'DEBUG', module: 'nikita/lib/file/types/krb5_conf'
      options.target ?= '/etc/krb5.conf'
      @file.ini
        stringify: misc.ini.stringify_square_then_curly
      , options
      
## Dependencies

    misc = require '@nikitajs/core/lib/misc'
