
# `krb5_ktadd(options, callback)`

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
      return callback new Error 'Property keytab is required' unless options.keytab
      if /^\S+@\S+$/.test options.kadmin_principal
        options.realm ?= options.kadmin_principal.split('@')[1]
      else
        throw Error 'Property "realm" is required unless present in principal' unless options.realm
        options.principal = "#{options.principal}@#{options.realm}"
      status = false
      do_get = =>
        return do_end() unless options.keytab
        @execute
          cmd: "export TZ=GMT; klist -kt #{options.keytab}"
          code_skipped: 1
        , (err, exists, stdout, stderr) ->
          return callback err if err
          unless exists
            options.log? 'Mecano `krb5_ktadd`: keytab does not yet exists'
            return do_ktadd() 
          keytab = {}
          for line in string.lines stdout
            if match = /^\s*(\d+)\s+([\d\/:]+\s+[\d\/:]+)\s+(.*)\s*$/.exec line
              [_, kvno, mdate, principal] = match
              kvno = parseInt kvno, 10
              mdate = Date.parse "#{mdate} GMT"
              # keytab[principal] ?= {kvno: null, mdate: null}
              if not keytab[principal] or keytab[principal].kvno < kvno
                keytab[principal] = kvno: kvno, mdate: mdate
          unless keytab[options.principal]?
            options.log? 'Mecano `krb5_ktadd`: Principal is not listed inside the keytab'
            return do_ktadd() 
          @execute
            cmd: misc.kadmin options, "getprinc -terse #{options.principal}"
          , (err, exists, stdout, stderr) ->
            return err if err
            # return do_ktadd() unless -1 is stdout.indexOf 'does not exist'
            values = string.lines(stdout)[1]
            # Check if a ticket exists for this
            return callback Error "Principal does not exist: '#{options.principal}'" unless values
            values = values.split '\t'
            mdate = parseInt(values[2], 10) * 1000
            kvno = parseInt values[8], 10
            options.log? "Mecano `krb5_ktadd`: keytab kvno '#{keytab[principal]?.kvno}', principal kvno '#{kvno}'"
            options.log? "Mecano `krb5_ktadd`: keytab mdate '#{new Date keytab[principal]?.mdate}', principal mdate '#{new Date mdate}'"
            if keytab[principal]?.kvno is kvno and keytab[principal].mdate is mdate
              options.log? 'Mecano `krb5_ktadd`: kvno and mdate are ok, continue with changing the keytab'
              return do_chown()
            do_ktremove()
      do_ktremove = =>
        @execute
          cmd: misc.kadmin options, "ktremove -k #{options.keytab} #{options.principal}"
        , (err, exists, stdout, stderr) ->
          return callback err if err
          do_ktadd()
      do_ktadd = =>
        @
        # .execute
        #   cmd: 'echo `hostname`'
        .execute
          cmd: misc.kadmin options, "ktadd -k #{options.keytab} #{options.principal}"
        , (err, ktadded) ->
          return callback err if err
          status = true
          do_chown()
      do_chown = =>
        @child()
        .chown
          destination: options.keytab
          uid: options.uid
          gid: options.gid
          if:  options.uid? or options.gid?
        .chmod
          destination: options.keytab
          mode: options.mode
          if: options.mode?
        .then (err, changed) ->
          return callback err if err
          status = changed if changed
          do_end()
      do_end = =>
        callback null, status
      do_get()

## Fields in 'getprinc -terse' output

princ-canonical-name
princ-exp-time
last-pw-change
pw-exp-time
princ-max-life
modifying-princ-canonical-name
princ-mod-date
princ-attributes <=== This is the field you want
princ-kvno
princ-mkvno
princ-policy (or 'None')
princ-max-renewable-life
princ-last-success
princ-last-failed
princ-fail-auth-count
princ-n-key-data
ver
kvno
data-type[0]
data-type[1]

## Dependencies

    misc = require './misc'
    string = require './misc/string'


