
# `nikita.krb5.ktadd(options, [callback])`

Create and manage a keytab. This function is usually not used directly but instead
called by the `krb5.addprinc` function.

## Options

* `kadmin_server`   
  Address of the kadmin server; optional, use "kadmin.local" if missing.   
* `kadmin_principal`   
  KAdmin principal name unless `kadmin.local` is used.   
* `kadmin_password`   
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
  kadmin_principal: 'me/admin@MY_REALM',
  kadmin_password: 'pass',
  kadmin_server: 'localhost'
}, function(err, status){
  console.log(err ? err.message : 'Principal removed: ' + status);
});
```

## Source Code

    module.exports = ({options}) ->
      throw Error 'Property principal is required' unless options.principal
      throw Error 'Property keytab is required' unless options.keytab
      if /^\S+@\S+$/.test options.kadmin_principal
        options.realm ?= options.kadmin_principal.split('@')[1]
      else
        throw Error 'Property "realm" is required unless present in principal' unless options.realm
        options.principal = "#{options.principal}@#{options.realm}"
      keytab = {} # keytab[principal] ?= {kvno: null, mdate: null}
      princ = {} # {kvno: null, mdate: null}
      # Get keytab information
      @system.execute
        cmd: "export TZ=GMT; klist -kt #{options.keytab}"
        code_skipped: 1
        shy: true
      , (err, {status, stdout}) ->
        throw err if err
        return unless status
        @log message: "Keytab exists, check kvno validity", level: 'DEBUG', module: 'nikita/krb5/ktadd'
        for line in string.lines stdout
          continue unless match = /^\s*(\d+)\s+([\d\/:]+\s+[\d\/:]+)\s+(.*)\s*$/.exec line
          [_, kvno, mdate, principal] = match
          kvno = parseInt kvno, 10
          mdate = Date.parse "#{mdate} GMT"
          # keytab[principal] ?= {kvno: null, mdate: null}
          if not keytab[principal] or keytab[principal].kvno < kvno
            keytab[principal] = kvno: kvno, mdate: mdate
      # Get principal information
      @system.execute
        cmd: misc.kadmin options, "getprinc -terse #{options.principal}"
        shy: true
        if: -> keytab[options.principal]?
      , (err, {status, stdout}) ->
        return err if err
        return unless status
        # return do_ktadd() unless -1 is stdout.indexOf 'does not exist'
        values = string.lines(stdout)[1]
        # Check if a ticket exists for this
        throw Error "Principal does not exist: '#{options.principal}'" unless values
        values = values.split '\t'
        mdate = parseInt(values[2], 10) * 1000
        kvno = parseInt values[8], 10
        princ = mdate: mdate, kvno: kvno
        @log message: "Keytab kvno '#{keytab[options.principal]?.kvno}', principal kvno '#{princ.kvno}'", level: 'INFO', module: 'nikita/krb5/ktadd'
        @log message: "Keytab mdate '#{new Date keytab[options.principal]?.mdate}', principal mdate '#{new Date princ.mdate}'", level: 'INFO', module: 'nikita/krb5/ktadd'
      # Remove principal from keytab
      @system.execute
        cmd: misc.kadmin options, "ktremove -k #{options.keytab} #{options.principal}"
        if: ->
          keytab[options.principal]? and (keytab[options.principal]?.kvno isnt princ.kvno or keytab[options.principal].mdate isnt princ.mdate)
      # Create keytab and add principal
      @system.mkdir
        target: "#{path.dirname options.keytab}"
        if: -> not keytab[options.principal]? or (keytab[options.principal]?.kvno isnt princ.kvno or keytab[options.principal].mdate isnt princ.mdate)
      @system.execute
        cmd: misc.kadmin options, "ktadd -k #{options.keytab} #{options.principal}"
        if: -> not keytab[options.principal]? or (keytab[options.principal]?.kvno isnt princ.kvno or keytab[options.principal].mdate isnt princ.mdate)
      # Keytab ownership and permissions
      @system.chown
        target: options.keytab
        uid: options.uid
        gid: options.gid
        if:  options.uid? or options.gid?
      @system.chmod
        target: options.keytab
        mode: options.mode
        if: options.mode?

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

    path = require 'path'
    misc = require '@nikitajs/core/lib/misc'
    string = require '@nikitajs/core/lib/misc/string'
