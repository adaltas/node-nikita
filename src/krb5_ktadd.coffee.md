
# `krb5_ktadd([goptions], options, callback`

Create and manage a keytab. This function is usually not used directly but instead
called by the `krb5_addprinc` function.   

## Options

*   `kadmin_server`   
    Address of the kadmin server; optional, use "kadmin.local" if missing.   
*   `kadmin_principal`   
    KAdmin principal name unless `kadmin.local` is used.   
*   `kadmin_password`   
    Password associated to the KAdmin principal.   
*   `principal`   
    Principal to be created.   
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
          return next new Error 'Property keytab is required' unless options.keytab
          # options.realm ?= options.principal.split('@')[1] # Break cross-realm principals
          options.realm ?= options.kadmin_principal.split('@')[1] if /.*@.*/.test options.kadmin_principal
          modified = false
          do_get = ->
            return do_end() unless options.keytab
            execute
              cmd: "klist -k #{options.keytab}"
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
              code_skipped: 1
            , (err, exists, stdout, stderr) ->
              return next err if err
              return do_ktadd() unless exists
              keytab = {}
              for line in stdout.split '\n'
                if match = /^\s*(\d+)\s*(.*)\s*$/.exec line
                  [_, kvno, principal] = match
                  keytab[principal] = kvno
              # Principal is not listed inside the keytab
              return do_ktadd() unless keytab[options.principal]?
              execute
                cmd: misc.kadmin options, "getprinc #{options.principal}"
                ssh: options.ssh
                log: options.log
                stdout: options.stdout
                stderr: options.stderr
              , (err, exists, stdout, stderr) ->
                return err if err
                return do_ktadd() unless -1 is stdout.indexOf 'does not exist'
                vno = null
                for line in stdout.split '\n'
                  if match = /Key: vno (\d+)/.exec line
                    [_, vno] = match
                    break
                return do_chown() if keytab[principal] is vno
                do_ktadd()
          do_ktadd = ->
            execute
              cmd: misc.kadmin options, "ktadd -k #{options.keytab} #{options.principal}"
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, ktadded) ->
              return next err if err
              modified = true
              do_chown()
          do_chown = () ->
            return do_chmod() if not options.keytab or (not options.uid and not options.gid)
            chown
              ssh: options.ssh
              log: options.log
              destination: options.keytab
              uid: options.uid
              gid: options.gid
            , (err, chowned) ->
              return next err if err
              modified = chowned if chowned
              do_chmod()
          do_chmod = () ->
            return do_end() if not options.keytab or not options.mode
            chmod
              ssh: options.ssh
              log: options.log
              destination: options.keytab
              mode: options.mode
            , (err, chmoded) ->
              return next err if err
              modified = chmoded if chmoded
              do_end()
          do_end = ->
            executed++ if modified
            next()
          conditions.all options, next, do_get
        .on 'both', (err) ->
          callback err, executed

## Dependencies

    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'
    chmod = require './chmod'
    chown = require './chown'


