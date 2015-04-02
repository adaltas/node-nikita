
# `krb5_principal(options, [goptions], callback)`

Create a new Kerberos principal with a password or an optional keytab.   

## Options

*   `kadmin_server`   
    Address of the kadmin server; optional, use "kadmin.local" if missing.   
*   `kadmin_principal`   
    KAdmin principal name unless `kadmin.local` is used.   
*   `kadmin_password`   
    Password associated to the KAdmin principal.   
*   `principal`   
    Principal to be created.   
*   `password`   
    Password associated to this principal; required if no randkey is
    provided.   
*   `randkey`   
    Generate a random key; required if no password is provided.   
*   `keytab`   
    Path to the file storing key entries.   
*   `log`   
    Function called with a log related messages.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Keytab example

```js
require('mecano').krb5_addprinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  randkey: true,
  keytab: '/etc/security/keytabs/my.service.keytab',
  uid: 'myservice',
  gid: 'myservice',
  kadmin_principal: 'me/admin@MY_REALM',
  kadmin_password: 'pass',
  kadmin_server: 'localhost'
}, function(err, modified){
  console.log(err ? err.message : 'Principal created or modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      wrap @, arguments, (options, callback) ->
        return callback new Error 'Property principal is required' unless options.principal
        return callback new Error 'Password or randkey missing' if not options.password and not options.randkey
        modified = false
        do_kadmin = ->
          # options.realm ?= options.principal.split('@')[1] # Break cross-realm principals
          options.realm ?= options.kadmin_principal.split('@')[1] if /.*@.*/.test options.kadmin_principal
          # options.principal = options.principal.split('@')[0] if options.principal.indexOf(options.realm) isnt -1
          options.principal = "#{options.principal}@#{options.realm}" unless /^\S+@\S+$/.test options.principal
          cmd = misc.kadmin options, if options.password
          then "addprinc -pw #{options.password} #{options.principal}"
          else "addprinc -randkey #{options.principal}"
          execute
            cmd: cmd
            ssh: options.ssh
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err, _, stdout, stderr) ->
            return callback err if err
            modified = true if -1 is stderr.indexOf 'already exists'
            do_keytab()
        do_keytab = ->
          krb5_ktadd options, (err, ktadded) ->
            modified = true if ktadded
            do_end()
        do_end = ->
          callback null, modified
        do_kadmin()

## Dependencies

    misc = require './misc'
    wrap = require './misc/wrap'
    execute = require './execute'
    krb5_ktadd = require './krb5_ktadd'

