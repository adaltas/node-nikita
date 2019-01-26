
require('@nikita/core/lib/registry')
.register
  ldap:
    acl: '@nikita/ldap/src/acl'
    add: '@nikita/ldap/src/add'
    delete: '@nikita/ldap/src/delete'
    index: '@nikita/ldap/src/index'
    schema: '@nikita/ldap/src/schema'
    user: '@nikita/ldap/src/user'
