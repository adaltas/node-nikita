
# `ldap_add(options, callback)`

Insert or modify an entry inside an OpenLDAP server.   

## Options

*   `entry` (object | array)   
    Object to be inserted or modified.   
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
  entry: {
    dn: 'cn=group1,ou=groups,dc=company,dc=com'
    cn: 'group1'
    objectClass: 'top'
    objectClass: 'posixGroup'
    gidNumber: 9601
  }
}, function(err, modified){
  console.log(err ? err.message : 'Entry modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      wrap @, arguments, (options, callback) ->
        modified = false
        return callback Error "Mecano `ldap_add`: required property 'entry'" unless options.entry
        options.entry = [options.entry] unless Array.isArray options.entry
        ldif = ''
        for entry in options.entry
          return callback Error "Mecano `ldap_add`: required property 'dn'" unless entry.dn
          ldif += '\n'
          ldif += "dn: #{entry.dn}\n"
          [_, k, v] = /^(.*?)=(.+?),.*$/.exec entry.dn
          ldif += "#{k}: #{v}\n"
          for k, v of entry
            continue if k is 'dn'
            v = [v] unless Array.isArray v
            for vv in v
              ldif += "#{k}: #{vv}\n"
        # We keep -c for now because we accept multiple entries. In the future, 
        # we shall detect modification and be more strict.
        # -c  Continuous operation mode.  Errors are reported, but ldapmodify will
        # continue with modifications.  The default is to exit after reporting an
        # error.
        execute
          cmd: """
          ldapadd -c -H #{options.url} \
            -D #{options.binddn} -w #{options.passwd} \
            <<-EOF\n#{ldif}\nEOF
          """
          code_skipped: 68
          ssh: options.ssh
          log: options.log
          stdout: options.stdout
          stderr: options.stderr
        , (err, executed, stdout, stderr) ->
          return callback err if err
          modified = stderr.match(/Already exists/g)?.length isnt stdout.match(/adding new entry/g).length
          added = modified # For now, we dont modify
          callback err, modified, added

## Dependencies

    execute = require './execute'
    wrap = require './misc/wrap'



