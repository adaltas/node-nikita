
# `nikita.krb5.delprinc(options, [callback])`

Remove a Kerberos principal and optionally its keytab.

## Options

* `admin.server`   
  Address of the kadmin server; optional, use "kadmin.local" if missing.   
* `admin.principal`   
  KAdmin principal name unless `kadmin.local` is used.   
* `admin.password`   
  Password associated to the KAdmin principal.   
* `principal`   
  Principal to be created.   
* `keytab`   
  Path to the file storing key entries.   

## Example

```
require('nikita')
.krb5_delrinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  admin: {
    principal: 'me/admin@MY_REALM',
    password: 'pass',
    server: 'localhost'
  }
}, function(err, status){
  console.info(err ? err.message : 'Principal removed: ' + status);
});
```

## Hooks

    on_options = ({options}) ->
      # Import all properties from `options.krb5`
      if options.krb5
        mutate options, options.krb5
        delete options.krb5

## Handler

    handler = ({options}) ->
      return throw Error 'Property principal is required' unless options.principal
      # Normalize realm and principal for later usage of options
      options.realm ?= options.admin.principal.split('@')[1] if /.*@.*/.test options.admin.principal
      options.principal = "#{options.principal}@#{options.realm}" unless /^\S+@\S+$/.test options.principal
      # Prepare commands
      @krb5.execute
        options:
          admin: options.admin
          cmd: "getprinc #{options.principal}"
          egrep: new RegExp "^.*#{misc.regexp.escape options.principal}$"
        metadata:
          shy: true
      @krb5.execute
        if: -> @status -1
        options:
          admin: options.admin
          cmd: "delprinc -force #{options.principal}"
      @system.remove
        target: options.keytab
        if: options.keytab

## Export

    module.exports =
      handler: handler
      on_options: on_options

## Dependencies

    misc = require '@nikitajs/core/lib/misc'
    {mutate} = require 'mixme'
