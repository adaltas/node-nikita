
# `ldap_index(options, callback)`

Create new [index](index) for the OpenLDAP server.

## Options

*   `indexes`   
    Object with keys mapping to indexed attributes and values mapping to indices
    ("pres", "approx", "eq", "sub" and 'special').   
*   `url`   
    Specify URI referring to the ldap server.   
*   `binddn`   
    Distinguished Name to bind to the LDAP directory.   
*   `passwd`   
    Password for simple authentication.   
*   `name`   
    Distinguish name storing the "olcAccess" property, using the database adress
    (eg: "olcDatabase={2}bdb,cn=config").   
*   `overwrite`   
    Overwrite existing "olcAccess", default is to merge.   

## Example

```js
require('mecano').ldap_index({
  url: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'olcDatabase={2}bdb,cn=config',
  indexes: {
    krbPrincipalName: 'sub,eq'
  }
}, function(err, modified){
  console.log(err ? err.message : 'Index modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      modified = false
      do_getdn = =>
        return do_get_indexes() if options.hdb_dn
        options.log message: "Get DN of the HDB to modify", level: 'DEBUG', module: 'mecano/ldap/index'
        @execute
          cmd: """
          ldapsearch -LLL -Y EXTERNAL -H ldapi:/// \
            -b cn=config \
            "(olcSuffix= #{options.suffix})" dn \
            2>/dev/null \
            | egrep '^dn' \
            | sed -e 's/^dn:\\s*olcDatabase=\\(.*\\)$/\\1/g'
          """
        , (err, _, hdb_dn) ->
          return callback err if err
          options.hdb_dn = hdb_dn.trim()
          do_get_indexes()
      do_get_indexes = =>
        options.log message: "List all indexes of the directory", level: 'DEBUG', module: 'mecano/ldap/index'
        @execute
          cmd: """
          ldapsearch -LLL -Y EXTERNAL -H ldapi:/// \
            -b olcDatabase=#{options.hdb_dn} \
            "(olcDbIndex=*)" olcDbIndex
          """
        , (err, _, stdout) ->
          return callback err if err
          indexes = {}
          for line in string.lines stdout
            continue unless match = /^olcDbIndex:\s+(.*)\s+(.*)/.exec line
            [_, attrlist, indices] = match
            indexes[attrlist] = indices
          do_diff indexes
      do_diff = (orgp) ->
        add = {}
        modify = {}
        for k, v of options.indexes
          if not orgp[k]?
            add[k] = v
          else if v != orgp[k]
            modify[k] = [v, orgp[k]]
        if Object.keys(add).length or Object.keys(modify).length then do_save(add, modify) else do_end()
      do_save = (add, modify) =>
        cmd = []
        for k, v of add
          cmd.push """
          add: olcDbIndex
          olcDbIndex: #{k} #{v}
          """
        for k, v of modify
          cmd.push """
          delete: olcDbIndex
          olcDbIndex: #{k} #{v[1]}
          -
          add: olcDbIndex
          olcDbIndex: #{k} #{v[0]}
          """
        @execute
          cmd: """
          ldapmodify -Y EXTERNAL -H ldapi:/// <<-EOF
          dn: olcDatabase=#{options.hdb_dn}
          changetype: modify
          #{cmd.join '\n-\n'}
          EOF
          """
        , (err, _, stdout) ->
          return callback err if err
          modified = true
          do_end()
      do_end = (err) ->
        callback err, modified
      do_getdn()

## Dependencies

    ldap = require 'ldapjs'
    misc = require '../misc'
    string = require '../misc/string'

[index]: http://www.zytrax.com/books/ldap/apa/indeces.html
