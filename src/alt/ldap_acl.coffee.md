
# `ldap_acl(options, [goptions], callback)`

Create new [ACLs](acls) for the OpenLDAP server.   

This implementation currently doesn't execute remote SSH commands. Instead, it
connects directly to the LDAP database and thus requires a specific port to be
accessible.   

## Options

*   `to`   
    What to control access to as a string.   
*   `by`   
    Who to grant access to and the access to grant as an array
    (eg: `{..., by:["ssf=64 anonymous auth"]}`).   
*   `url`   
    Specify URI referring to the ldap server, alternative to providing an
    [ldapjs client] instance.   
*   `binddn`   
    Distinguished Name to bind to the LDAP directory, alternative to providing
    an [ldapjs client] instance.   
*   `passwd`   
    Password for simple authentication, alternative to providing an
    [ldapjs client] instance.   
*   `ldap`   
    Instance of an [ldapjs client][ldapclt], alternative to providing the `url`,
    `binddn` and `passwd` connection properties.   
*   `unbind`   
    Close the ldap connection, default to false if connection is an
    [ldapjs client][ldapclt] instance.   
*   `name`   
    Distinguish name storing the "olcAccess" property, using the database adress
    (eg: "olcDatabase={2}bdb,cn=config").   
*   `overwrite`   
    Overwrite existing "olcAccess", default is to merge.   
*   `log`   
    Function called with a log related messages.   
*   `acl`   
    In case of multiple acls, regroup "before", "to" and "by" as an array.   

## Example

```js
require('mecano/alt/ldap_acl')({
  url: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'olcDatabase={2}bdb,cn=config',
  acls: [{
    before: 'dn.subtree="dc=domain,dc=com"',
    to: 'dn.subtree="ou=users,dc=domain,dc=com"',
    by: [
      'dn.exact="ou=users,dc=domain,dc=com" write',
      "dn.base='gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth' read",
      "* none"
    ]
  },{
    to: 'dn.subtree="dc=domain,dc=com"',
    by: [
      'dn.exact="ou=kerberos,dc=domain,dc=com" write'
    ]
  }]
}, function(err, modified){
  console.log(err ? err.message : "ACL modified: " + !!modified);
});
```

    module.exports = (goptions, options, callback) ->
      options.acls ?= [{}]
      updated = false
      each(options.acls)
      .call (acl, next) ->
        acl.before ?= options.before
        acl.to ?= options.to
        acl.by ?= options.by
        client = null
        acl.to = acl.to.trim()
        for b, i in acl.by
          acl.by[i] = b.trim()
        connect = ->
          # if options.ldap instanceof ldap_client
          if options.ldap?.url?.protocol?.indexOf('ldap') is 0
            client = options.ldap
            return search()
          options.log? 'Open and bind connection'
          client = ldap.createClient url: options.url
          client.bind options.binddn, options.passwd, (err) ->
            return end err if err
            search()
        search = ->
            options.log? 'Search attribute olcAccess'
            client.search options.name,
              scope: 'base'
              attributes: ['olcAccess']
            , (err, search) ->
              return unbind err if err
              olcAccess = null
              search.on 'searchEntry', (entry) ->
                options.log? "Found #{JSON.stringify entry.object}"
                # typeof olcAccess may be undefined, array or string
                olcAccess = entry.object.olcAccess or []
                olcAccess = [olcAccess] unless Array.isArray olcAccess
              search.on 'end', ->
                options.log? "Attribute olcAccess was #{JSON.stringify olcAccess}"
                parse olcAccess
        parse = (_olcAccess) ->
          olcAccess = []
          for access, i in _olcAccess
            to = ''
            bys = []
            buftype = 0 # 0: start, 1: to, 2:by
            buf = ''
            for c, i in access
              buf += c
              if buftype is 0
                if /to$/.test buf
                  buf = ''
                  buftype = 1
              if buftype is 1
                if matches = /^(.*)by$/.exec buf
                  to = matches[1].trim()
                  buf = ''
                  buftype = 2
              if buftype is 2
                if matches = /^(.*)by$/.exec buf
                  bys.push matches[1].trim()
                  buf = ''
                else if i+1 is access.length
                  bys.push buf.trim()
            olcAccess.push
              to: to
              by: bys
          do_diff olcAccess
        do_diff = (olcAccess) ->
          toAlreadyExist = false
          for access, i in olcAccess
            continue unless acl.to is access.to
            toAlreadyExist = true
            fby = unless options.overwrite then access.by else []
            for oby in acl.by
              found = false
              for aby in access.by
                if oby is aby
                  found = true
                  break
              unless found
                updated = true
                fby.push oby
            olcAccess[i].by = fby
          unless toAlreadyExist
            updated = true
            # place before
            if acl.before
              found = null
              for access, i in olcAccess
                found = i if access.to is acl.before
              # throw new Error 'Before does not match any "to" rule' unless found?
              olcAccess.splice found-1, 0, to: acl.to, by: acl.by
            # place after
            else if acl.after
              found = false
              for access, i in olcAccess
                found = i if access.to is options.after
              # throw new Error 'After does not match any "to" rule'
              olcAccess.splice found, 0, to: acl.to, by: acl.by
            # append
            else
              olcAccess.push to: acl.to, by: acl.by
          if updated then stringify(olcAccess) else unbind()
        stringify = (olcAccess) ->
          for access, i in olcAccess
            value = "{#{i}}to #{access.to}"
            for bie in access.by
              value += " by #{bie}"
            olcAccess[i] = value
          save olcAccess
        save = (olcAccess) ->
          change = new ldap.Change
            operation: 'replace'
            modification: olcAccess: olcAccess
          client.modify options.name, change, (err) ->
            unbind err
        unbind = (err) ->
          options.log? 'Unbind connection'
          # return end err if options.ldap instanceof ldap_client and not options.unbind
          return end err if options.ldap?.url?.protocol?.indexOf('ldap') is 0 and not options.unbind
          client.unbind (e) ->
            return next e if e
            end err
        end = (err) ->
          next err
        connect()
      .then (err) ->
        next err, updated

## Dependencies

    each = require 'each'
    ldap = require 'ldapjs'
    wrap = require '../misc/wrap'

[acls]: http://www.openldap.org/doc/admin24/access-control.html
[ldapclt]: http://ldapjs.org/client.html
