
# `nikita.ldap.index`

Create new [index](index) for the OpenLDAP server.

## Options

* `indexes`   
  Object with keys mapping to indexed attributes and values mapping to indices
  ("pres", "approx", "eq", "sub" and 'special').   
* `url`   
  Specify URI referring to the ldap server.   
* `binddn`   
  Distinguished Name to bind to the LDAP directory.   
* `passwd`   
  Password for simple authentication.   
* `name`   
  Distinguish name storing the "olcAccess" property, using the database adress
  (eg: "olcDatabase={2}bdb,cn=config").   
* `overwrite`   
  Overwrite existing "olcAccess", default is to merge.   

## Example

```js
require('nikita')
.ldap.index({
  url: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'olcDatabase={2}bdb,cn=config',
  indexes: {
    krbPrincipalName: 'sub,eq'
  }
}, function(err, status){
  console.log(err ? err.message : 'Index modified: ' + status);
});
```

## Source Code

    module.exports = ({options}) ->
      modified = false
      indexes = {}
      add = {}
      modify = {}
      @call unless: options.hdb_dn, ->
        @log message: "Get DN of the HDB to modify", level: 'DEBUG', module: 'nikita/ldap/index'
        @system.execute
          shy: true
          cmd: """
          ldapsearch -LLL -Y EXTERNAL -H ldapi:/// \
            -b cn=config \
            "(olcSuffix= #{options.suffix})" dn \
            2>/dev/null \
            | egrep '^dn' \
            | sed -e 's/^dn:\\s*olcDatabase=\\(.*\\)$/\\1/g'
          """
          shy: true
        , (err, data) ->
          throw err if err
          @log message: "HDB is #{data.stdout.trim()}", level: 'INFO', module: 'nikita/ldap/index'
          options.hdb_dn = data.stdout.trim()
      @call ->
        @log message: "List all indexes of the directory", level: 'DEBUG', module: 'nikita/ldap/index'
        @system.execute
          shy: true
          cmd: """
          ldapsearch -LLL -Y EXTERNAL -H ldapi:/// \
            -b olcDatabase=#{options.hdb_dn} \
            "(olcDbIndex=*)" olcDbIndex
          """
        , (err, data) ->
          throw err if err
          for line in string.lines data.stdout
            continue unless match = /^olcDbIndex:\s+(.*)\s+(.*)/.exec line
            [_, attrlist, indices] = match
            indexes[attrlist] = indices
      @call (_, callback) ->
        for k, v of options.indexes
          if not indexes[k]?
            add[k] = v
          else if v != indexes[k]
            modify[k] = [v, indexes[k]]
        callback null, Object.keys(add).length? or Object.keys(modify).length?
      @call if: (-> @status -1), ->
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
        @system.execute
          cmd: """
          ldapmodify -Y EXTERNAL -H ldapi:/// <<-EOF
          dn: olcDatabase=#{options.hdb_dn}
          changetype: modify
          #{cmd.join '\n-\n'}
          EOF
          """

## Dependencies

    misc = require '@nikita/core/lib/misc'
    string = require '@nikita/core/lib/misc/string'

[index]: http://www.zytrax.com/books/ldap/apa/indeces.html
