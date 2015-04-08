
# `ldap_user(options, callback)`

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
*   `url`   
    Specify URI referring to the ldap server.   
*   `user`   
    User object.   

## Example

```js
require('mecano').ldap_user({
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
      wrap @, arguments, (options, callback) ->
        modified = false
        return callback Error "Mecano `ldap_user`: required property 'user'" unless options.user
        options.user = [options.user] unless Array.isArray options.user
        each(options.user)
        .on 'item', (user, callback) ->
          do_user = ->
            entry = {}
            for k, v of user
              continue if k is 'userPassword'
              entry[k] = v
            ldap_add
              entry: entry
              url: options.url
              binddn: options.binddn
              passwd: options.passwd
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, modified, added) ->
              return callback err if err
              modified = true if modified or added
              if added
              then do_ldappass()
              else do_checkpass()
          do_checkpass = ->
            execute
              cmd: """
                ldapsearch -H ldapi:/// \
                  -D #{user.dn} -w #{user.userPassword} \
                  -b '#{user.dn}'
              """
              code_skipped: 1
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, exists, stdout) ->
              if err then do_ldappass() else do_end()
          do_ldappass = ->
            execute
              cmd: """
              ldappasswd -H #{options.url} \
                -D #{options.binddn} -w #{options.passwd} \
                '#{user.dn}' \
                -s #{user.userPassword}
              """
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err) ->
              return callback err if err
              modified = true
              do_end()
          do_end = ->
            callback()
          do_user()
        .on 'both', (err) ->
          callback err, modified

## Dependencies

    each = require 'each'
    execute = require './execute'
    ldap_add = require './ldap_add'
    wrap = require './misc/wrap'

[index]: http://www.zytrax.com/books/ldap/apa/indeces.html


