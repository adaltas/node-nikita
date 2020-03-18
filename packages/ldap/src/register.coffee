
# registration of `nikita.ldap` actions

## Dependency

    {register} = require '@nikitajs/core/lib/registry'

## Action registration

    register module.exports =
      ldap:
        acl: '@nikitajs/ldap/src/acl'
        add: '@nikitajs/ldap/src/add'
        delete: '@nikitajs/ldap/src/delete'
        index: '@nikitajs/ldap/src/index'
        schema: '@nikitajs/ldap/src/schema'
        user: '@nikitajs/ldap/src/user'
