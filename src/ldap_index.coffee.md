
# `ldap_index([goptions], options, callback`

Create new [index](index) for the OpenLDAP server.   

## Options

*   `indexes`   
    Object with keys mapping to indexed attributes and values mapping to indices
    ("pres", "approx", "eq", "sub" and 'special').   
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
    Instance of an pldapjs client][ldapclt], alternative to providing the `url`,
    `binddn` and `passwd` connection properties.   
*   `unbind`   
    Close the ldap connection, default to false if connection is an
    [ldapjs client][ldapclt] instance.   
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
  console.log(err ? err.message : "Index modified: " + !!modified);
});
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      result = child()
      finish = (err, created) ->
        callback err, created if callback
        result.end err, created
      misc.options options, (err, options) ->
        return finish err if err
        modified = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          client = null
          updated = false
          connect = ->
            # if options.ldap instanceof ldap_client
            if options.ldap?.url?.protocol?.indexOf('ldap') is 0
              client = options.ldap
              return get()
            # Open and bind connection
            client = ldap.createClient url: options.url
            client.bind options.binddn, options.passwd, (err) ->
              return end err if err
              get()
          get = ->
            client.search 'olcDatabase={2}bdb,cn=config',
                scope: 'base'
                attributes: ['olcDbIndex']
            , (err, search) ->
              olcDbIndex = null
              search.on 'searchEntry', (entry) ->
                olcDbIndex = entry.object.olcDbIndex
              search.on 'end', ->
                parse olcDbIndex
          parse = (arIndex) ->
            indexes = {}
            for index in arIndex
              [k,v] = index.split ' '
              indexes[k] = v
            do_diff indexes
          do_diff = (orgp) ->
            unless options.overwrite
              newp = misc.merge {}, orgp, options.indexes
            else
              newp = options.indexes
            okl = Object.keys(orgp).sort()
            nkl = Object.keys(newp).sort()
            for i in [0...Math.min(okl.length, nkl.length)]
              if i is okl.length or i is nkl.length or okl[i] isnt nkl[i] or orgp[okl[i]] isnt newp[nkl[i]]
                updated = true
                break
            if updated then stringifiy newp else unbind()
          stringifiy = (perms) ->
            indexes = []
            for k, v of perms
              indexes.push "#{k} #{v}"
            replace indexes
          replace = (indexes) ->
            change = new ldap.Change
              operation: 'replace'
              modification:
                olcDbIndex: indexes
            client.modify options.name, change, (err) ->
              unbind err
          unbind = (err) ->
            # return end err if options.ldap instanceof ldap_client and not options.unbind
            return end err if options.ldap?.url?.protocol?.indexOf('ldap') is 0 and not options.unbind
            client.unbind (e) ->
              return next e if e
              end err
          end = (err) ->
            modified += 1 if updated and not err
            next err
          conditions.all options, next, connect
        .on 'both', (err) ->
          finish err, modified
      result

## Dependencies

    each = require 'each'
    ldap = require 'ldapjs'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'

[index]: http://www.zytrax.com/books/ldap/apa/indeces.html


