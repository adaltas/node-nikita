
# `krb5_delprinc(options, callback)`

Remove a Kerberos principal and optionally its keytab.   

## Options

*   `principal`   
    Principal to be created.   
*   `kadmin_server`   
    Address of the kadmin server; optional, use "kadmin.local" if missing.   
*   `kadmin_principal`   
    KAdmin principal name unless `kadmin.local` is used.   
*   `kadmin_password`   
    Password associated to the KAdmin principal.   
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

## Example

```
require('mecano').krb5_delrinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  kadmin_principal: 'me/admin@MY_REALM',
  kadmin_password: 'pass',
  kadmin_server: 'localhost'
}, function(err, removed){
  console.log(err ? err.message : 'Principal removed: ' + !!removed);
});
```

## Source Code

    module.exports = (options, callback) ->
      wrap @, arguments, (options, callback) ->
        return callback new Error 'Property principal is required' unless options.principal
        modified = false
        do_delprinc = ->
          execute
            cmd: misc.kadmin options, "delprinc -force #{options.principal}"
            ssh: options.ssh
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err, _, stdout) ->
            return callback err if err
            modified = true if -1 is stdout.indexOf 'does not exist'
            do_keytab()
        do_keytab = ->
          return do_end() unless options.keytab
          remove
            ssh: options.ssh
            destination: options.keytab
          , (err, removed) ->
            return callback err if err
            modified++ if removed
            do_end()
        do_end = ->
          callback null, modified
        do_delprinc()

## Dependencies

    misc = require './misc'
    wrap = require './misc/wrap'
    execute = require './execute'
    remove = require './remove'



