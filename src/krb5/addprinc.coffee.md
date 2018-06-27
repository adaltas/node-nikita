
# `nikita.krb5.addprinc(options, [callback])`

Create a new Kerberos principal with a password or an optional keytab.

## Options

* `kadmin_server`, `admin_server`   
  Address of the kadmin server; optional, use "kadmin.local" if missing.   
* `kadmin_principal`   
  KAdmin principal name unless `kadmin.local` is used.   
* `kadmin_password`   
  Password associated to the KAdmin principal.   
* `principal`   
  Principal to be created.   
* `password`   
  Password associated to this principal; required if no randkey is
  provided.   
* `password_sync`   
  Wether the password should be created if the principal already exists,
  default to "false".   
* `randkey`   
  Generate a random key; required if no password is provided.   
* `keytab`   
  Path to the file storing key entries.   

## Keytab example

```js
require('nikita').krb5.addprinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  randkey: true,
  keytab: '/etc/security/keytabs/my.service.keytab',
  uid: 'myservice',
  gid: 'myservice',
  kadmin_principal: 'me/admin@MY_REALM',
  kadmin_password: 'pass',
  kadmin_server: 'localhost'
}, function(err, {status}){
  console.log(err ? err.message : 'Principal created or modified: ' + !!status);
});
```

## Source Code

    module.exports = (options) ->
      return throw Error 'Property principal is required' unless options.principal
      return throw Error 'Password or randkey missing' if not options.password and not options.randkey
      # Normalize realm and principal for later usage of options
      options.realm ?= options.kadmin_principal.split('@')[1] if /.*@.*/.test options.kadmin_principal
      options.principal = "#{options.principal}@#{options.realm}" unless /^\S+@\S+$/.test options.principal
      options.password_sync ?= false
      options.kadmin_server ?= options.admin_server # Might deprecated kadmin_server in favor of admin_server
      # Prepare commands
      cmd_getprinc = misc.kadmin options, "getprinc #{options.principal}"
      cmd_addprinc = misc.kadmin options, if options.password
      then "addprinc -pw #{options.password} #{options.principal}"
      else "addprinc -randkey #{options.principal}"
      # todo, could be removed once actions acception multiple options arguments
      # such ash `.krb5.ktadd options, if: options.keytab
      ktadd_options = {}
      for k, v of options then ktadd_options[k] = v
      ktadd_options.if = options.keytab
      delete ktadd_options.header
      # Ticket cache location
      cache_name = "/tmp/nikita_#{Math.random()}"
      @system.execute
        retry: 3
        cmd: cmd_addprinc
        unless_exec: "#{cmd_getprinc} | grep '#{options.principal}'"
      @system.execute
        retry: 3
        cmd: misc.kadmin options, "cpw -pw #{options.password} #{options.principal}"
        if: options.password and options.password_sync
        unless_exec: """
        if ! echo #{options.password} | kinit '#{options.principal}' -c '#{cache_name}'; then exit 1; else kdestroy -c '#{cache_name}'; fi
        """
      @krb5.ktadd ktadd_options

## Dependencies

    misc = require '../misc'
