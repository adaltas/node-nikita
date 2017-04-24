
# `nikita.ldap.delete(options, [callback])`

Insert or modify an entry inside an OpenLDAP server.   

## Options

* `dn` (string | array)   
  One or multiple DN to remove.   
* `uri`   
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
require('nikita').ldap.delete({
  url: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  dn: 'cn=group1,ou=groups,dc=company,dc=com'
}, function(err, deleted){
  console.log(err ? err.message : 'Entry deleted: ' + deleted);
});
```

## Source Code

    module.exports = (options, callback) ->
      # Auth related options
      binddn = if options.binddn then "-D #{options.binddn}" else ''
      passwd = if options.passwd then "-w #{options.passwd}" else ''
      if options.url
        console.log "Nikita: option 'options.url' is deprecated, use 'options.uri'"
        options.uri ?= options.url
      options.uri = 'ldapi:///' if options.uri is true
      uri = if options.uri then "-H #{options.uri}" else '' # URI is obtained from local openldap conf unless provided
      # Add related options
      return callback Error "Nikita `ldap.delete`: required property 'dn'" unless options.dn
      options.dn = [options.dn] unless Array.isArray options.dn
      dn = options.dn.map( (dn) -> "'#{dn}'").join(' ')
      # ldapdelete -D cn=Manager,dc=ryba -w test -H ldaps://master3.ryba:636 'cn=nikita,ou=users,dc=ryba' 
      @system.execute
        cmd: "ldapdelete #{binddn} #{passwd} #{uri} #{dn}"
        # code_skipped: 68
      , (err, executed, stdout, stderr) ->
        return callback err if err
        callback err, executed
        # modified = stderr.match(/Already exists/g)?.length isnt stdout.match(/adding new entry/g).length
        # added = modified # For now, we dont modify
        # callback err, modified, added
