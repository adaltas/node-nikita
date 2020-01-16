// Generated by CoffeeScript 2.5.0
// # `nikita.ldap.index`

// Create new [index](index) for the OpenLDAP server.

// ## Options

// * `indexes`   
//   Object with keys mapping to indexed attributes and values mapping to indices
//   ("pres", "approx", "eq", "sub" and 'special').   
// * `url`   
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
//   name: 'olcDatabase={2}bdb,cn=config',
//   indexes: {
//     krbPrincipalName: 'sub,eq'
//   }
// }, function(err, status){
//   console.log(err ? err.message : 'Index modified: ' + status);
// });
// ```

// ## Source Code
var misc, string;

module.exports = function({options}) {
  var add, indexes, modified, modify;
  modified = false;
  indexes = {};
  add = {};
  modify = {};
  this.call({
    unless: options.hdb_dn
  }, function() {
    this.log({
      message: "Get DN of the HDB to modify",
      level: 'DEBUG',
      module: 'nikita/ldap/index'
    });
    return this.system.execute({
      shy: true,
      cmd: `ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn=config "(olcSuffix= ${options.suffix})" dn 2>/dev/null | egrep '^dn' | sed -e 's/^dn:\\s*olcDatabase=\\(.*\\)$/\\1/g'`,
      shy: true
    }, function(err, data) {
      if (err) {
        throw err;
      }
      this.log({
        message: `HDB is ${data.stdout.trim()}`,
        level: 'INFO',
        module: 'nikita/ldap/index'
      });
      return options.hdb_dn = data.stdout.trim();
    });
  });
  this.call(function() {
    this.log({
      message: "List all indexes of the directory",
      level: 'DEBUG',
      module: 'nikita/ldap/index'
    });
    return this.system.execute({
      shy: true,
      cmd: `ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b olcDatabase=${options.hdb_dn} "(olcDbIndex=*)" olcDbIndex`
    }, function(err, data) {
      var _, attrlist, i, indices, len, line, match, ref, results;
      if (err) {
        throw err;
      }
      ref = string.lines(data.stdout);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        line = ref[i];
        if (!(match = /^olcDbIndex:\s+(.*)\s+(.*)/.exec(line))) {
          continue;
        }
        [_, attrlist, indices] = match;
        results.push(indexes[attrlist] = indices);
      }
      return results;
    });
  });
  this.call(function(_, callback) {
    var k, ref, v;
    ref = options.indexes;
    for (k in ref) {
      v = ref[k];
      if (indexes[k] == null) {
        add[k] = v;
      } else if (v !== indexes[k]) {
        modify[k] = [v, indexes[k]];
      }
    }
    return callback(null, (Object.keys(add).length != null) || (Object.keys(modify).length != null));
  });
  return this.call({
    if: (function() {
      return this.status(-1);
    })
  }, function() {
    var cmd, k, v;
    cmd = [];
    for (k in add) {
      v = add[k];
      cmd.push(`add: olcDbIndex
olcDbIndex: ${k} ${v}`);
    }
    for (k in modify) {
      v = modify[k];
      cmd.push(`delete: olcDbIndex
olcDbIndex: ${k} ${v[1]}
-
add: olcDbIndex
olcDbIndex: ${k} ${v[0]}`);
    }
    return this.system.execute({
      cmd: `ldapmodify -Y EXTERNAL -H ldapi:/// <<-EOF
dn: olcDatabase=${options.hdb_dn}
changetype: modify
${cmd.join('\n-\n')}
EOF`
    });
  });
};

// ## Dependencies
misc = require('@nikitajs/core/lib/misc');

string = require('@nikitajs/core/lib/misc/string');

// [index]: http://www.zytrax.com/books/ldap/apa/indeces.html
