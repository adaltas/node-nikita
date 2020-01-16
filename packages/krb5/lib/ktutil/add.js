// Generated by CoffeeScript 2.5.0
// # `nikita.krb5.ktutil(options, [callback])`

// Create and manage a keytab for an existing principal. It's different than ktadd
// in the way it can manage several principal on one keytab.

// ## Options

// * `admin.server`   
//   Address of the kadmin server; optional, use "kadmin.local" if missing.   
// * `admin.principal`   
//   KAdmin principal name unless `kadmin.local` is used.   
// * `admin.password`   
//   Password associated to the KAdmin principal.   
// * `principal`   
//   Principal to be inserted.   
// * `password`   
//   Password of the principal.   
// * `keytab`    
//   Path to the file storing key entries.   
// * `realm`   
//   The realm the principal belongs to. optional
// * `enctypes`   
//   the enctypes used by krb5_server. optional

// ## Example

// ```
// require('nikita').krb5.ktutil.add({
//   principal: 'myservice/my.fqdn@MY.REALM',
//   keytab: '/etc/security/keytabs/my.service.keytab',
//   password: 'password'
// }, function(err, status){
//   console.info(err ? err.message : 'Keytab created or modified: ' + status);
// });
// ```

// ## Hooks
var handler, misc, mutate, on_options, path, string;

on_options = function({options}) {
  // Import all properties from `options.krb5`
  if (options.krb5) {
    mutate(options, options.krb5);
    return delete options.krb5;
  }
};

// ## Source Code
handler = function({options}) {
  var cmd, entries, princ, princ_entries;
  if (!options.principal) {
    throw Error('Property principal is required');
  }
  if (!options.keytab) {
    throw Error('Property keytab is required');
  }
  if (!options.password) {
    throw Error('Property password is required');
  }
  if (/^\S+@\S+$/.test(options.principal)) {
    if (options.realm == null) {
      options.realm = options.principal.split('@')[1];
    }
  } else {
    if (!options.realm) {
      throw Error('Property "realm" is required in principal');
    }
    options.principal = `${options.principal}@${options.realm}`;
  }
  entries = [];
  princ_entries = [];
  princ = {};
  if (options.enctypes == null) {
    options.enctypes = ['aes256-cts-hmac-sha1-96', 'aes128-cts-hmac-sha1-96', 'des3-cbc-sha1', 'arcfour-hmac'];
  }
  cmd = null;
  // Get keytab entries
  this.system.execute({
    cmd: `echo -e 'rkt ${options.keytab}\nlist -e -t \n' | ktutil`,
    code_skipped: 1,
    shy: true
  }, function(err, {status, stdout}) {
    var _, enctype, i, kvno, len, line, match, principal, ref, slot, timestamp;
    if (err) {
      throw err;
    }
    if (!status) {
      return;
    }
    this.log({
      message: "Principal exist in Keytab, check kvno validity",
      level: 'DEBUG',
      module: 'nikita/krb5/ktutil/add'
    });
    ref = string.lines(stdout);
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      if (!(match = /^\s*(\d+)\s*(\d+)\s+([\d\/:]+\s+[\d\/:]+)\s+(.*)\s*\(([\w|-]*)\)\s*$/.exec(line))) {
        continue;
      }
      [_, slot, kvno, timestamp, principal, enctype] = match;
      kvno = parseInt(kvno, 10);
      entries.push({
        slot: slot,
        kvno: kvno,
        timestamps: timestamp,
        principal: principal.trim(),
        enctype: enctype
      });
    }
    return princ_entries = entries.filter(function(e) {
      return `${e.principal}` === `${options.principal}`;
    }).reverse();
  });
  // Get principal information and compare to keytab entries kvnos
  this.krb5.execute({
    admin: options.admin,
    cmd: `getprinc -terse ${options.principal}`,
    shy: true
  }, function(err, {status, stdout}) {
    var kvno, mdate, values;
    if (err) {
      return err;
    }
    if (!status) {
      return;
    }
    values = string.lines(stdout)[1];
    if (!values) {
      // Check if a ticket exists for this
      throw Error(`Principal does not exist: '${options.principal}'`);
    }
    values = values.split('\t');
    mdate = parseInt(values[2], 10) * 1000;
    kvno = parseInt(values[8], 10);
    return princ = {
      mdate: mdate,
      kvno: kvno
    };
  });
  // read keytab and check kvno validities
  this.call(function() {
    var enctype, entry, i, len, ref, tmp_keytab;
    cmd = null;
    tmp_keytab = `${options.keytab}.tmp_nikita_${Date.now()}`;
    ref = options.enctypes;
    for (i = 0, len = ref.length; i < len; i++) {
      enctype = ref[i];
      entry = princ_entries.filter(function(entry) {
        return entry.enctype === enctype;
      }).length === 1 ? entries.filter(function(entry) {
        return entry.enctype === enctype;
      })[0] : null;
      //entries.filter( (entry) -> entry.enctype is enctype).length is 1
      // add_entry_cmd = "add_entry -password -p #{options.principal} -k #{princ.kvno} -e #{enctype}\n#{options.password}\n"
      if ((entry != null) && ((entry != null ? entry.kvno : void 0) !== princ.kvno)) {
        if (cmd == null) {
          cmd = `echo -e 'rkt ${options.keytab}\n`;
        }
        // remove entry if kvno not identical
        this.log({
          message: `Remove from Keytab kvno '${entry.kvno}', principal kvno '${princ.kvno}'`,
          level: 'INFO',
          module: 'nikita/krb5/ktutil/add'
        });
        cmd += `delete_entry ${entry != null ? entry.slot : void 0}\n`;
      }
    }
    this.call({
      if: entries.length > princ_entries.length
    }, function() {
      this.system.execute({
        if: function() {
          return cmd != null;
        },
        cmd: cmd + `wkt ${tmp_keytab}\nquit\n' | ktutil`
      });
      return this.system.move({
        if: function() {
          return cmd != null;
        },
        source: tmp_keytab,
        target: options.keytab
      });
    });
    return this.system.remove({
      if: (entries.length === princ_entries.length) && (cmd != null),
      target: options.keytab
    });
  });
  // write entries in keytab
  this.call(function() {
    var enctype, entry, i, len, ref;
    cmd = null;
    ref = options.enctypes;
    for (i = 0, len = ref.length; i < len; i++) {
      enctype = ref[i];
      entry = princ_entries.filter(function(entry) {
        return entry.enctype === enctype;
      }).length === 1 ? entries.filter(function(entry) {
        return entry.enctype === enctype;
      })[0] : null;
      if (((entry != null ? entry.kvno : void 0) !== princ.kvno) || (entry == null)) {
        if (cmd == null) {
          cmd = "echo -e '";
        }
        cmd += `add_entry -password -p ${options.principal} -k ${princ.kvno} -e ${enctype}\n${options.password}\n`;
      }
    }
    return this.system.execute({
      if: function() {
        return cmd != null;
      },
      cmd: cmd + `wkt ${options.keytab}\n' | ktutil`
    });
  });
  // Keytab ownership and permissions
  this.system.chown({
    target: options.keytab,
    uid: options.uid,
    gid: options.gid,
    if: (options.uid != null) || (options.gid != null)
  });
  return this.system.chmod({
    target: options.keytab,
    mode: options.mode,
    if: options.mode != null
  });
};

// ## Export
module.exports = {
  handler: handler,
  on_options: on_options
};

// ## Fields in 'getprinc -terse' output

// princ-canonical-name
// princ-exp-time
// last-pw-change
// pw-exp-time
// princ-max-life
// modifying-princ-canonical-name
// princ-mod-date
// princ-attributes <=== This is the field you want
// princ-kvno
// princ-mkvno
// princ-policy (or 'None')
// princ-max-renewable-life
// princ-last-success
// princ-last-failed
// princ-fail-auth-count
// princ-n-key-data
// ver
// kvno
// data-type[0]
// data-type[1]

// ## Dependencies
path = require('path');

misc = require('@nikitajs/core/lib/misc');

string = require('@nikitajs/core/lib/misc/string');

({mutate} = require('mixme'));
