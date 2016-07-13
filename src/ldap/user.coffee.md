
# `ldap.user(options, callback)`

Create and modify a user store inside an OpenLDAP server.   

## Options

*   `binddn`   
    Distinguished Name to bind to the LDAP directory.   
*   `passwd`   
    Password for simple authentication.   
*   `name`   
    Distinguish name storing the "olcAccess" property, using the database adress
    (eg: "olcDatabase={2}bdb,cn=config").   
*   `overwrite`   
    Overwrite existing "olcAccess", default is to merge.   
*   `uri`   
    Specify URI referring to the ldap server.   
*   `user`   
    User object.   

## Example

```js
require('mecano').ldap.user({
  url: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  user: {
  }
}, function(err, modified){
  console.log(err ? err.message : 'Index modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      # Auth related options
      binddn = if options.binddn then "-D #{options.binddn}" else ''
      passwd = if options.passwd then "-w #{options.passwd}" else ''
      if options.url
        console.log "Mecano: option 'options.url' is deprecated, use 'options.uri'"
        options.uri ?= options.url
      options.uri = 'ldapi:///' if options.uri is true
      uri = if options.uri then "-H #{options.uri}" else '' # URI is obtained from local openldap conf unless provided
      # User related options
      return callback Error "Mecano `ldap.user`: required property 'user'" unless options.user
      options.user = [options.user] unless Array.isArray options.user
      modified = false
      each(options.user)
      .call (user, callback) =>
        do_user = =>
          entry = {}
          for k, v of user
            continue if k is 'userPassword'
            entry[k] = v
          @ldap.add
            entry: entry
            uri: options.uri
            binddn: options.binddn
            passwd: options.passwd
          , (err, updated, added) ->
            return callback err if err
            if added then options.log message: "User added", level: 'WARN', module: 'mecano/ldap/user'
            else if updated then options.log message: "User updated", level: 'WARN', module: 'mecano/ldap/user'
            modified = true if updated or added
            if added
            then do_ldappass()
            else do_checkpass()
        do_checkpass = =>
          return do_end() unless user.userPassword
          @execute
            # See https://onemoretech.wordpress.com/2011/09/22/verifying-ldap-passwords/
            cmd: """
            ldapsearch -D #{user.dn} -w #{user.userPassword} #{uri} -b "" -s base "objectclass=*"
            """
            code_skipped: 49
          , (err, identical, stdout) ->
            return callback err if err
            if identical then do_end() else do_ldappass()
        do_ldappass = =>
          return do_end() unless user.userPassword
          @execute
            cmd: """
            ldappasswd #{binddn} #{passwd} #{uri} \
              -s #{user.userPassword} \
              '#{user.dn}'
            """
          , (err) ->
            return callback err if err
            options.log message: "Password modified", level: 'WARN', module: 'mecano/ldap/user'
            modified = true
            do_end()
        do_end = ->
          callback()
        do_user()
      .then (err) ->
        callback err, modified

## Note

A user can modify it's own password with the "ldappasswd" command if ACL allows
it. Here's an example:

```bash
ldappasswd -D cn=myself,ou=users,dc=ryba -w oldpassword \
  -H ldaps://master3.ryba:636 \
  -s newpassword 'cn=myself,ou=users,dc=ryba'
```

## Dependencies

    each = require 'each'

[index]: http://www.zytrax.com/books/ldap/apa/indeces.html
