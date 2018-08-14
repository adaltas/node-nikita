
# `nikita.krb5.ticket(options, [callback])`

Renew the Kerberos ticket of a user principal inside a Unix session.

## Options

* `principal`   
  Principal to be created.   
* `password`   
  Password associated to this principal; required if no randkey is
  provided.   
* `keytab`   
  Path to the file storing key entries.   
* `cache_name` (string)    
  Path to Kerberos cache file.    
* `uid`   
  Unix uid or username of the Unix session   

## Keytab example

```js
require('nikita')
.krb5.ticket({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
}, function(err, {status}){
  console.log(err ? err.message : 'Is ticket renewed: ' + status);
});
```

## Source Code

    module.exports = ({options}) ->
      throw Error "Incoherent options: expects one of keytab or password" if not options.keytab and not options.password
      # SSH connection
      ssh = @ssh options.ssh
      @system.uid_gid
        uid: options.uid
        gid: options.gid
        shy: true
      , (err, {status, uid, gid, default_gid}) ->
        options.uid = uid
        options.gid = gid
      @system.execute
        cmd: """
        if #{krb5.su options, 'klist -s'}; then exit 3; fi
        #{krb5.kinit options}
        """
        code_skipped: 3
      @system.chown
        if: options.uid? or options.gid?
        uid: options.uid
        gid: options.gid
        target: options.target

## Dependencies

    krb5 = require '../misc/krb5'
