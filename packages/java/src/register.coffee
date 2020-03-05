
# registration of `nikita.java` actions

## Dependency

    {register} = require '@nikitajs/core/lib/registry'

## Action registration

    register
      java:
        keystore_add: '@nikitajs/java/src/keystore_add'
        keystore_remove: '@nikitajs/java/src/keystore_remove'
