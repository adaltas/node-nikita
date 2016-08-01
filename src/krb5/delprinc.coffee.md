
# `mecano.krb5.delprinc(options, [callback])`

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
      return callback new Error 'Property principal is required' unless options.principal
      # Normalize realm and principal for later usage of options
      options.realm ?= options.kadmin_principal.split('@')[1] if /.*@.*/.test options.kadmin_principal
      options.principal = "#{options.principal}@#{options.realm}" unless /^\S+@\S+$/.test options.principal
      # Prepare commands
      cmd_getprinc = misc.kadmin options, "getprinc #{options.principal}"
      cmd_delprinc = misc.kadmin options, "delprinc -force #{options.principal}"
      @execute
        cmd: cmd_delprinc
        if_exec: "#{cmd_getprinc} | grep '#{options.principal}'"
      @remove
        target: options.keytab
        if: options.keytab
      @then callback

## Dependencies

    misc = require '../misc'
