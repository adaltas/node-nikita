
# `nikita.krb5.ktutil(options, [callback])`

Create and manage a keytab for an existing principal. It's different than ktadd
in the way it can manage several principal on one keytab.

## Options

* `kadmin_server`   
  Address of the kadmin server; optional, use "kadmin.local" if missing.   
* `kadmin_principal`   
  KAdmin principal name unless `kadmin.local` is used.   
* `kadmin_password`   
  Password associated to the KAdmin principal.   
* `principal`   
  Principal to be inserted.   
* `password`   
  Password of the principal.   
* `keytab`    
  Path to the file storing key entries.   
* `realm`   
  The realm the principal belongs to. optional
* `enctypes`   
  the enctypes used by krb5_server. optional

## Example

```
require('nikita').krb5.ktutil.add({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  password: 'password'
}, function(err, status){
  console.log(err ? err.message : 'Keytab created or modified: ' + status);
});
```

## Source Code

    module.exports = ({options}) ->
      throw Error 'Property principal is required' unless options.principal
      throw Error 'Property keytab is required' unless options.keytab
      throw Error 'Property password is required' unless options.password
      if /^\S+@\S+$/.test options.principal
        options.realm ?= options.principal.split('@')[1]
      else
        throw Error 'Property "realm" is required in principal' unless options.realm
        options.principal = "#{options.principal}@#{options.realm}"
      entries = []
      princ_entries = []
      princ = {}
      options.enctypes ?= ['aes256-cts-hmac-sha1-96','aes128-cts-hmac-sha1-96','des3-cbc-sha1','arcfour-hmac']
      cmd = null
      # Get keytab entries
      @system.execute
        cmd: "echo -e 'rkt #{options.keytab}\nlist -e -t \n' | ktutil"
        code_skipped: 1
        shy: true
      , (err, {status, stdout}) ->
        throw err if err
        return unless status
        @log message: "Principal exist in Keytab, check kvno validity", level: 'DEBUG', module: 'nikita/krb5/ktutil/add'
        for line in string.lines stdout
          continue unless match = /^\s*(\d+)\s*(\d+)\s+([\d\/:]+\s+[\d\/:]+)\s+(.*)\s*\(([\w|-]*)\)\s*$/.exec line
          [_, slot, kvno, timestamp, principal, enctype] = match
          kvno = parseInt kvno, 10
          entries.push
            slot: slot
            kvno: kvno
            timestamps: timestamp
            principal: principal.trim()
            enctype: enctype
        princ_entries = entries.filter((e) -> "#{e.principal}" is "#{options.principal}").reverse()
      # Get principal information and compare to keytab entries kvnos
      @system.execute
        cmd: misc.kadmin options, "getprinc -terse #{options.principal}"
        shy: true
      , (err, {status, stdout}) ->
        return err if err
        return unless status
        values = string.lines(stdout)[1]
        # Check if a ticket exists for this
        throw Error "Principal does not exist: '#{options.principal}'" unless values
        values = values.split '\t'
        mdate = parseInt(values[2], 10) * 1000
        kvno = parseInt values[8], 10
        princ = mdate: mdate, kvno: kvno
      # read keytab and check kvno validities
      @call ->
        cmd = null
        tmp_keytab = "#{options.keytab}.tmp_nikita_#{Date.now()}"
        for enctype in options.enctypes
          entry = if princ_entries.filter( (entry) -> entry.enctype is enctype).length is 1 then entries.filter( (entry) -> entry.enctype is enctype)[0] else null
          #entries.filter( (entry) -> entry.enctype is enctype).length is 1
          # add_entry_cmd = "add_entry -password -p #{options.principal} -k #{princ.kvno} -e #{enctype}\n#{options.password}\n"
          if entry? and (entry?.kvno isnt princ.kvno)
            cmd ?= "echo -e 'rkt #{options.keytab}\n"
            # remove entry if kvno not identical
            @log message: "Remove from Keytab kvno '#{entry.kvno}', principal kvno '#{princ.kvno}'", level: 'INFO', module: 'nikita/krb5/ktutil/add'
            cmd += "delete_entry #{entry?.slot}\n"
        @call
          if: entries.length > princ_entries.length
        , ->
          @system.execute
            if: -> cmd?
            cmd: cmd + "wkt #{tmp_keytab}\nquit\n' | ktutil"
          @system.move
            if: -> cmd?
            source: tmp_keytab
            target: options.keytab
        @system.remove
          if: (entries.length is princ_entries.length) and cmd?
          target: options.keytab
      # write entries in keytab
      @call ->
        cmd = null
        for enctype in options.enctypes
          entry = if princ_entries.filter( (entry) -> entry.enctype is enctype).length is 1 then entries.filter( (entry) -> entry.enctype is enctype)[0] else null
          if (entry?.kvno isnt princ.kvno) or !entry?
            cmd ?= "echo -e '"
            cmd += "add_entry -password -p #{options.principal} -k #{princ.kvno} -e #{enctype}\n#{options.password}\n"
        @system.execute
          if: -> cmd?
          cmd: cmd + "wkt #{options.keytab}\n' | ktutil"
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
    misc = require '../../misc'
    string = require '../../misc/string'
