
# `nikita.krb5.addprinc(options, [callback])`

Create a new Kerberos principal with a password or an optional keytab.

## Options

* `admin.server`   
  Address of the kadmin server; optional, use "kadmin.local" if missing.   
* `admin.principal`   
  KAdmin principal name unless `kadmin.local` is used.   
* `admin.password`   
  Password associated to the KAdmin principal.   
* `keytab`   
  Path to the file storing key entries.   
* `password`   
  Password associated to this principal; required if no randkey is
  provided.   
* `password_sync`   
  Wether the password should be created if the principal already exists,
  default to "false".   
* `principal`   
  Principal to be created.   
* `randkey`   
  Generate a random key; required if no password is provided.   

## Keytab example

```js
require('nikita').krb5.addprinc({
  admin: {
    password: 'pass',
    principal: 'me/admin@MY_REALM',
    server: 'localhost'
  },
  keytab: '/etc/security/keytabs/my.service.keytab',
  gid: 'myservice',
  principal: 'myservice/my.fqdn@MY.REALM',
  randkey: true,
  uid: 'myservice'
}, function(err, {status}){
  console.info(err ? err.message : 'Principal created or modified: ' + status);
});
```

## Schema

    schema =
      type: 'object'
      properties:
        'admin':
          $ref: '/nikita/krb5/execute#/properties/admin'
        'keytab': type: 'string'
        'password': type: 'string'
        'password_sync': type: 'boolean', default: false
        'principal': type: 'string'
        'randkey': type: 'boolean', default: false
      required: [
        'admin', 'principal'
      ]

## Hooks

    on_options = ({options}) ->
      # Import all properties from `options.krb5`
      if options.krb5
        mutate options, options.krb5
        delete options.krb5
      # Extract realm
      options.admin.realm ?= options.admin.principal.split('@')[1] if /.*@.*/.test options.admin?.principal

## Handler

    handler = ({options}) ->
      return throw Error 'Password or randkey missing' if not options.password and not options.randkey
      # Normalize realm and principal for later usage of options
      options.principal = "#{options.principal}@#{options.admin.realm}" unless /^\S+@\S+$/.test options.principal
      # Ticket cache location
      cache_name = "/tmp/nikita_#{Math.random()}"
      # Start execution
      @krb5.execute
        options:
          admin: options.admin
          cmd: "getprinc #{options.principal}"
          egrep: new RegExp "^.*#{misc.regexp.escape options.principal}$"
        metadata:
          shy: true
      @krb5.execute
        unless: -> @status -1
        options:
          admin: options.admin
          cmd: if options.password
          then "addprinc -pw #{options.password} #{options.principal}"
          else "addprinc -randkey #{options.principal}"
        metadata:
          retry: 3
      @krb5.execute
        if: options.password and options.password_sync
        unless_exec: """
        if ! echo #{options.password} | kinit '#{options.principal}' -c '#{cache_name}'; then exit 1; else kdestroy -c '#{cache_name}'; fi
        """
        options:
          admin: options.admin
          cmd: "cpw -pw #{options.password} #{options.principal}"
        metadata:
          retry: 3
      @krb5.ktadd options, if: !!options.keytab

## Export

    module.exports =
      handler: handler
      on_options: on_options
      schema: schema

## Dependencies

    misc = require '@nikitajs/core/lib/misc'
    {mutate} = require 'mixme'
