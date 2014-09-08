
# `krb5_delprinc([goptions], options, callback`

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
*   `ssh`   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `log`   
    Function called with a log related messages.   
*   `stdout`   
    Writable Stream in which commands output will be piped.   
*   `stderr`   
    Writable Stream in which commands error will be piped.   

## Example

```
require('mecano').krb5_delrinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  kadmin_principal: 'me/admin@MY_REALM',
  kadmin_password: 'pass',
  kadmin_server: 'localhost'
}, function(err, removed){
  console.log(err ? err.message : "Principal removed: " + !!removed);
});
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      misc.options options, (err, options) ->
        return callback err if err
        executed = 0
        each(options)
        .parallel( goptions.parallel )
        .on 'item', (options, next) ->
          return next new Error 'Property principal is required' unless options.principal
          modified = true
          do_delprinc = ->
            execute
              cmd: misc.kadmin options, "delprinc -force #{options.principal}"
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, _, stdout) ->
              return next err if err
              modified = true if -1 is stdout.indexOf 'does not exist'
              do_keytab()
          do_keytab = ->
            return do_end() unless options.keytab
            remove
              ssh: options.ssh
              destination: options.keytab
            , (err, removed) ->
              return next err if err
              modified++ if removed
              do_end()
          do_end = ->
            executed++ if modified
            next()
          conditions.all options, next, do_delprinc
        .on 'both', (err) ->
          callback err, executed

## Dependencies

    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'
    remove = require './remove'



