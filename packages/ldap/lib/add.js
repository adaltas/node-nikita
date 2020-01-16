// Generated by CoffeeScript 2.5.0
// # `nikita.ldap.add`

// Insert or modify an entry inside an OpenLDAP server.   

// ## Options

// * `entry` (object | array)   
//   Object to be inserted or modified.   
// * `uri`   
//   Specify URI referring to the ldap server.   
// * `binddn`   
//   Distinguished Name to bind to the LDAP directory.   
// * `passwd`   
//   Password for simple authentication.   
// * `name`   
//   Distinguish name storing the "olcAccess" property, using the database adress
//   (eg: "olcDatabase={2}bdb,cn=config").   
// * `overwrite`   
//   Overwrite existing "olcAccess", default is to merge.   

// ## Example

// ```js
// require('nikita')
// .ldap.index({
//   url: 'ldap://openldap.server/',
//   binddn: 'cn=admin,cn=config',
//   passwd: 'password',
//   entry: {
//     dn: 'cn=group1,ou=groups,dc=company,dc=com'
//     cn: 'group1'
//     objectClass: 'top'
//     objectClass: 'posixGroup'
//     gidNumber: 9601
//   }
// }, function(err, status){
//   console.log(err ? err.message : 'Entry modified: ' + status);
// });
// ```

// ## Source Code
module.exports = function({options}, callback) {
  var _, binddn, entry, i, j, k, ldif, len, len1, modified, passwd, ref, uri, v, vv;
  // Auth related options
  binddn = options.binddn ? `-D ${options.binddn}` : '';
  passwd = options.passwd ? `-w ${options.passwd}` : '';
  if (options.url) {
    console.log("Nikita: option 'options.url' is deprecated, use 'options.uri'");
    if (options.uri == null) {
      options.uri = options.url;
    }
  }
  if (options.uri === true) {
    options.uri = 'ldapi:///';
  }
  uri = options.uri ? `-H ${options.uri}` : ''; // URI is obtained from local openldap conf unless provided
  if (!options.entry) {
    // Add related options
    return callback(Error("Nikita `ldap.add`: required property 'entry'"));
  }
  if (!Array.isArray(options.entry)) {
    options.entry = [options.entry];
  }
  ldif = '';
  ref = options.entry;
  for (i = 0, len = ref.length; i < len; i++) {
    entry = ref[i];
    if (!entry.dn) {
      return callback(Error("Nikita `ldap.add`: required property 'dn'"));
    }
    ldif += '\n';
    ldif += `dn: ${entry.dn}\n`;
    [_, k, v] = /^(.*?)=(.+?),.*$/.exec(entry.dn);
    ldif += `${k}: ${v}\n`;
    if (entry[k]) {
      if (entry[k] !== v) {
        throw Error(`Inconsistent value: ${entry[k]} is not ${v} for attribute ${k}`);
      }
      delete entry[k];
    }
    for (k in entry) {
      v = entry[k];
      if (k === 'dn') {
        continue;
      }
      if (!Array.isArray(v)) {
        v = [v];
      }
      for (j = 0, len1 = v.length; j < len1; j++) {
        vv = v[j];
        ldif += `${k}: ${vv}\n`;
      }
    }
  }
  modified = false;
  // We keep -c for now because we accept multiple entries. In the future, 
  // we shall detect modification and be more strict.
  // -c  Continuous operation mode.  Errors are reported, but ldapmodify will
  // continue with modifications.  The default is to exit after reporting an
  // error.
  return this.system.execute({
    cmd: `ldapadd -c ${binddn} ${passwd} ${uri} <<-EOF
${ldif}
EOF`,
    code_skipped: 68
  }, function(err, data) {
    var added, ref1;
    if (err) {
      return callback(err);
    }
    modified = ((ref1 = data.stderr.match(/Already exists/g)) != null ? ref1.length : void 0) !== data.stdout.match(/adding new entry/g).length;
    added = modified; // For now, we dont modify
    return callback(err, modified, added);
  });
};
